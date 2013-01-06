require Rails.root.join('lib', 'runner')
#require Rails.root.join('lib', 'scheduler_job')
require 'scheduler_job'

# Custom Redis configuration
config_file = Rails.root.join('config', 'resque.yml')

if File.exists?(config_file)
  resque_config = YAML.load_file(config_file)
  Resque.redis = resque_config[Rails.env]
end

Resque.redis.namespace = 'resque:gitlab_ci'

# Queues
Resque.watch_queue(Runner.instance_variable_get("@queue"))

# Authentication
require 'resque/server'
class Authentication
  def initialize(app)
    @app = app
  end

  def call(env)
    account = env['warden'].authenticate!(:database_authenticatable, :rememberable, scope: :user)
    raise "Access denied" if !account#.admin?
    @app.call(env)
  end
end

Resque::Server.use Authentication

# Mailer
# For future email notifications
#Resque::Mailer.excluded_environments = []
