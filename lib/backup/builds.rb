module Backup
  class Builds
    attr_reader :app_builds_dir, :backup_builds_tarball, :backup_dir

    def initialize
      @app_builds_dir = File.realpath(Rails.root.join('builds'))
      @backup_dir = GitlabCi.config.backup.path
      @backup_builds_tarball = File.join(GitlabCi.config.backup.path, 'builds/builds.tar.gz')
    end

    # Copy builds from builds directory to backup/builds
    def dump
      FileUtils.mkdir_p(File.dirname(backup_builds_tarball))
      FileUtils.rm_f(backup_builds_tarball)

      # Use 'tar -czf -' instead of 'tar -cz' because on some systems the
      # default behavior of tar is to talk to a tape device instead of
      # stdin/stdout.
      system(
        *%W(tar -C #{app_builds_dir} -czf - -- .),
        out: [backup_builds_tarball, 'w', 0600]
      )
    end

    def restore
      backup_existing_builds_dir
      Dir.mkdir(app_builds_dir, 0700)

      # Use 'tar -xzf -' instead of 'tar -xz' because on some systems the
      # default behavior of tar is to talk to a tape device instead of
      # stdin/stdout.
      system(
        *%W(tar -C #{app_builds_dir} -xzf -),
        in: backup_builds_tarball
      )
    end

    def backup_existing_builds_dir
      timestamped_builds_path = File.join(app_builds_dir, '..', "builds.#{Time.now.to_i}")
      if File.exists?(app_builds_dir)
        FileUtils.mv(app_builds_dir, File.expand_path(timestamped_builds_path))
      end
    end
  end
end
