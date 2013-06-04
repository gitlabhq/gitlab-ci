module GitlabCi
  Version = File.read(Rails.root.join("VERSION"))
  Revision = `git log --pretty=format:'%h' -n 1`
  RunnersToken = SecureRandom.hex(10)

  def self.config
    Settings
  end
end
