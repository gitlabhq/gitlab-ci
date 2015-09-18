require 'yaml'

module Backup
  class Database
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

    def dump
      FileUtils.rm_f(db_file_name)
      compress_rd, compress_wr = IO.pipe
      compress_pid = spawn(*%W(gzip -c), in: compress_rd, out: [db_file_name, 'w', 0600])
      compress_rd.close

      dump_pid = case config["adapter"]
      when /^mysql/ then
        $progress.print "Dumping MySQL database #{config['database']} ... "
        spawn('mysqldump', *mysql_args, config['database'], *TABLES, out: compress_wr)
      when "postgresql" then
        $progress.print "Dumping PostgreSQL database #{config['database']} ... "
        pg_env
        spawn('pg_dump', '--clean', *TABLES.map { |t| "--table=#{t}" }, config['database'], out: compress_wr)
      end
      compress_wr.close

      success = [compress_pid, dump_pid].all? { |pid| Process.waitpid(pid); $?.success? }

      report_success(success)
      abort 'Backup failed' unless success
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
