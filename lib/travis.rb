require 'yaml'

module Travis
  class Config
    def initialize(path)
      @path = path.to_s
    end

    def scripts
      script = []
      script << (yml['before_script'] || [])
      script << (yml['script'] || [])
      script.flatten
    end

    def env
      (yml['env'] || []).first
    end

    def yml
      begin
        @yml ||= YAML.load(File.read @path)
      rescue Exception => e
        $stderr.puts e.message
        @yml = {}
      end
    end

    def to_runnable
      %{
set -e

unset GEM_PATH
unset GIT_SSH
unset GITLAB_CI_KEY
unset RAILS_ENV
unset RACK_ENV

export HOME='#{File.dirname @path}'

eval "(rbenv init -)" > /dev/null

test -f config/application.rb && mkdir -p tmp # for Rails applications

set -x

#{ "export #{env}" if env }

ruby --version
gem --version
bundle --version

test -f Gemfile && bundle install

#{ scripts.join("\n") }

true
      }
    end
  end
end
