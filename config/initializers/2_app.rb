module GitlabCi
  VERSION = File.read(Rails.root.join("VERSION")).strip

  # Try to read the current Git revision from a REVISION file. This is used by
  # the omnibus packages.
  revision_file = Rails.root.join('REVISION')
  if File.exist?(revision_file)
    REVISION = File.read(revision_file).strip
  else
    REVISION = `git log --pretty=format:'%h' -n 1`
  end

  REGISTRATION_TOKEN = SecureRandom.hex(10)

  def self.config
    Settings
  end
end
