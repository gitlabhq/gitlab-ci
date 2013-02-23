require 'yaml'
require 'fileutils'

module Travis
  class Config
    def initialize(project, path)
      @path = path.to_s
      @project = project
    end

    def scripts
      script = []
      script << (yml['before_script'] || [])
      script << (yml['script'] || [])
      script.flatten
    end

    def gem_home
      dir = @project.path.to_s + "/.rubygems"
      FileUtils.mkdir_p dir
      dir
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
unset BUNDLE_GEMFILE
unset BUNDLE_BIN_PATH
unset GEM_HOME
unset RUBYOPT
unset PORT
unset _ORIGINAL_GEM_PATH

test -f /etc/environment && . /etc/environment

export HOME='#{File.dirname @path}'
export LANG=en_US.UTF-8
export GEM_HOME=#{gem_home}
export PATH="/usr/lib/rbenv/shims:${PATH}"
export RBENV_DIR=$HOME

test -f config/application.rb && mkdir -p tmp # for Rails applications

set -x
env

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
