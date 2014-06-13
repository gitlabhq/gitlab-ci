module GitlabCi
  VERSION = File.read(Rails.root.join("VERSION")).strip
  REVISION = `git log --pretty=format:'%h' -n 1`
  REGISTRATION_TOKEN = SecureRandom.hex(10)

  def self.config
    Settings
  end
end
