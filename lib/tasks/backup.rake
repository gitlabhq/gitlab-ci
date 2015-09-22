namespace :backup do
  
  desc "GITLAB | Create a backup of the GitLab CI database"
  task create: :environment do
    configure_cron_mode
    mysql_to_postgresql = (ENV['MYSQL_TO_POSTGRESQL'] == '1')

    $progress.puts "Applying final database migrations ... ".blue
    Rake::Task['db:migrate'].invoke
    $progress.puts "done".green

    $progress.puts "Dumping database ... ".blue
    Backup::Database.new.dump(mysql_to_postgresql)
    $progress.puts "done".green

    $progress.puts "Dumping builds ... ".blue
    Backup::Builds.new.dump
    $progress.puts "done".green

    backup = Backup::Manager.new
    tar_file = backup.pack
    backup.cleanup
    backup.remove_old

    # Relax backup directory permissions to make the migration easier
    File.chmod(0755, GitlabCi.config.backup.path)

    $progress.puts "\n\nYour final CI export is in the following file:\n\n"
    system(*%W(ls -lh #{tar_file}))
    $progress.puts
  end

  desc "GITLAB | Show database secrets"
  task show_secrets: :environment do
    configure_cron_mode
    $progress.puts <<-EOS

If you are moving to a GitLab installation installed from source, replace the
contents of /home/git/gitlab/config/secrets.yml with the following:


---
production:
  db_key_base: #{JSON.dump(GitlabCi::Application.secrets.db_key_base)}


If your GitLab server uses Omnibus packages, add the following line to
/etc/gitlab/gitlab.rb:


gitlab_rails['db_key_base'] = #{GitlabCi::Application.secrets.db_key_base.inspect}


EOS
  end

  desc "GITLAB | Restore a previously created backup"
  task restore: :environment do
    configure_cron_mode

    backup = Backup::Manager.new
    backup.unpack

    $progress.puts "Restoring database ... ".blue
    Backup::Database.new.restore
    $progress.puts "done".green

    $progress.puts "Restoring builds ... ".blue
    Backup::Builds.new.restore
    $progress.puts "done".green

    backup.cleanup
  end

  def configure_cron_mode
    if ENV['CRON']
      # We need an object we can say 'puts' and 'print' to; let's use a
      # StringIO.
      require 'stringio'
      $progress = StringIO.new
    else
      $progress = $stdout
    end
  end
end

# Disable colors for CRON
unless STDOUT.isatty
  module Colored
    extend self

    def colorize(string, options={})
      string
    end
  end
end
