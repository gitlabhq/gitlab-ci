class Settings < Settingslogic
  def self.root
    File.join(File.dirname(__FILE__), "..", "config")
  end

  source "#{self.root}/application.yml"

  def self.db_url
    @url ||= build_db_url
  end

  def self.build_db_url
    str = 'mysql2://'
    str << "#{db.username}:#{db.password}"
    str << "@#{db.host}"
    str << "/#{db.name}"
    str
  end
end
