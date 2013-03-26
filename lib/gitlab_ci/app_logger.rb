module GitlabCi
  class AppLogger < GitlabCi::Logger
    def self.file_name
      'application.log'
    end

    def format_message(severity, timestamp, progname, msg)
      "#{timestamp.to_s(:long)}: #{msg}\n"
    end
  end
end
