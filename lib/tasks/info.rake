namespace :env do
  desc "GITLAB | Show information about GitLab CI and its environment"
  task info: :environment  do

    # check if there is an RVM environment
    rvm_version = run_and_match("rvm --version", /[\d\.]+/).try(:to_s)
    # check Ruby version
    ruby_version = run_and_match("ruby --version", /[\d\.p]+/).try(:to_s)
    # check Gem version
    gem_version = run_and_match("gem --version", /.*/)
    # check Bundler version
    bunder_version = run_and_match("bundle --version", /[\d\.]+/).try(:to_s)
    # check Bundler version
    rake_version = run_and_match("rake --version", /[\d\.]+/).try(:to_s)

    puts ""
    puts "System information".yellow
    puts "System:\t\t#{os_name || "unknown".red}"
    puts "Current User:\t#{`whoami`}"
    puts "Using RVM:\t#{rvm_version.present? ? "yes".green : "no"}"
    puts "RVM Version:\t#{rvm_version}" if rvm_version.present?
    puts "Ruby Version:\t#{ruby_version || "unknown".red}"
    puts "Gem Version:\t#{gem_version || "unknown".red}"
    puts "Bundler Version:#{bunder_version || "unknown".red}"
    puts "Rake Version:\t#{rake_version || "unknown".red}"
    puts "Sidekiq Version:#{Sidekiq::VERSION}"


    # check database adapter
    database_adapter = ActiveRecord::Base.connection.adapter_name.downcase

    puts ""
    puts "GitLab CI information".yellow
    puts "Version:\t#{GitlabCi::VERSION}"
    puts "Revision:\t#{GitlabCi::REVISION}"
    puts "Directory:\t#{Rails.root}"
    puts "DB Adapter:\t#{database_adapter}"
  end
end

def run_and_match(command, regexp)
  `#{command}`.try(:match, regexp)
end

  # Check which OS is running
  #
  # It will primarily use lsb_relase to determine the OS.
  # It has fallbacks to Debian, SuSE, OS X and systems running systemd.
def os_name
  os_name = system("lsb_release -irs")
  os_name ||= if File.readable?('/etc/system-release')
                File.read('/etc/system-release')
              end
  os_name ||= if File.readable?('/etc/debian_version')
                debian_version = File.read('/etc/debian_version')
                "Debian #{debian_version}"
              end
  os_name ||= if File.readable?('/etc/SuSE-release')
                File.read('/etc/SuSE-release')
              end
  os_name ||= if os_x_version = `sw_vers -productVersion`
                "Mac OS X #{os_x_version}"
              end
  os_name ||= if File.readable?('/etc/os-release')
                File.read('/etc/os-release').match(/PRETTY_NAME=\"(.+)\"/)[1]
              end
  os_name.try(:squish!)
end
