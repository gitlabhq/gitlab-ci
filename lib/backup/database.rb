require 'yaml'
require 'open3'

module Backup
  class Database
    # These are the final CI tables (final prior to integration in GitLab)
    TABLES = %w{
      ci_application_settings ci_builds ci_commits ci_events ci_jobs ci_projects 
      ci_runner_projects ci_runners ci_services ci_tags ci_taggings ci_trigger_requests 
      ci_triggers ci_variables ci_web_hooks
    }

    attr_reader :config, :db_dir

    def initialize
      @config = YAML.load_file(File.join(Rails.root,'config','database.yml'))[Rails.env]
      @db_dir = File.join(GitlabCi.config.backup.path, 'db')
      FileUtils.mkdir_p(@db_dir) unless Dir.exists?(@db_dir)
    end

    def dump(mysql_to_postgresql=false)
      FileUtils.rm_f(db_file_name)
      compress_rd, compress_wr = IO.pipe
      compress_pid = spawn(*%W(gzip -c), in: compress_rd, out: [db_file_name, 'w', 0600])
      compress_rd.close

      dump_pid = case config["adapter"]
      when /^mysql/ then
        $progress.print "Dumping MySQL database #{config['database']} ... "
        args = mysql_args
        args << '--compatible=postgresql' if mysql_to_postgresql
        spawn('mysqldump', *args, config['database'], *TABLES, out: compress_wr)
      when "postgresql" then
        $progress.print "Dumping PostgreSQL database #{config['database']} ... "
        pg_env
        spawn('pg_dump', '--clean', *TABLES.map { |t| "--table=#{t}" }, config['database'], out: compress_wr)
      end
      compress_wr.close

      success = [compress_pid, dump_pid].all? { |pid| Process.waitpid(pid); $?.success? }

      report_success(success)
      abort 'Backup failed' unless success
      convert_to_postgresql if mysql_to_postgresql
    end

    def convert_to_postgresql
      mysql_dump_gz = db_file_name + '.mysql'
      psql_dump_gz = db_file_name + '.psql'
      drop_indexes_sql = File.join(db_dir, 'drop_indexes.sql')

      File.rename(db_file_name, mysql_dump_gz)

      $progress.print "Converting MySQL database dump to Postgres ... "
      statuses = Open3.pipeline(
        %W(gzip -cd #{mysql_dump_gz}),
        %W(python lib/support/mysql-postgresql-converter/db_converter.py - - #{drop_indexes_sql}),
        %W(gzip -c),
        out: [psql_dump_gz, 'w', 0600]
      )

      if !statuses.compact.all?(&:success?)
        abort "mysql-to-postgresql-converter failed"
      end
      $progress.puts '[DONE]'.green

      $progress.print "Splicing in 'DROP INDEX' statements ... "
      statuses = Open3.pipeline(
        %W(lib/support/mysql-postgresql-converter/splice_drop_indexes #{psql_dump_gz} #{drop_indexes_sql}),
        %W(gzip -c),
        out: [db_file_name, 'w', 0600]
      )
      if !statuses.compact.all?(&:success?)
        abort "Failed to splice in 'DROP INDEXES' statements"
      end

      $progress.puts '[DONE]'.green
    ensure
      FileUtils.rm_f([mysql_dump_gz, psql_dump_gz, drop_indexes_sql])
    end

    def restore
      decompress_rd, decompress_wr = IO.pipe
      decompress_pid = spawn(*%W(gzip -cd), out: decompress_wr, in: db_file_name)
      decompress_wr.close

      restore_pid = case config["adapter"]
      when /^mysql/ then
        $progress.print "Restoring MySQL database #{config['database']} ... "
        spawn('mysql', *mysql_args, config['database'], in: decompress_rd)
      when "postgresql" then
        $progress.print "Restoring PostgreSQL database #{config['database']} ... "
        pg_env
        spawn('psql', config['database'], in: decompress_rd)
      end
      decompress_rd.close

      success = [decompress_pid, restore_pid].all? { |pid| Process.waitpid(pid); $?.success? }

      report_success(success)
      abort 'Restore failed' unless success
    end

    protected

    def db_file_name
      File.join(db_dir, 'database.sql.gz')
    end

    def mysql_args
      args = {
        'host'      => '--host',
        'port'      => '--port',
        'socket'    => '--socket',
        'username'  => '--user',
        'encoding'  => '--default-character-set',
        'password'  => '--password'
      }
      args.map { |opt, arg| "#{arg}=#{config[opt]}" if config[opt] }.compact
    end

    def pg_env
      ENV['PGUSER']     = config["username"] if config["username"]
      ENV['PGHOST']     = config["host"] if config["host"]
      ENV['PGPORT']     = config["port"].to_s if config["port"]
      ENV['PGPASSWORD'] = config["password"].to_s if config["password"]
    end

    def report_success(success)
      if success
        $progress.puts '[DONE]'.green
      else
        $progress.puts '[FAILED]'.red
      end
    end
  end
end
