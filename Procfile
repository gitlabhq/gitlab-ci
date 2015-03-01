web: bundle exec unicorn_rails -p ${PORT:="3000"} -E ${RAILS_ENV:="development"} -c ${UNICORN_CONFIG:="config/unicorn.rb"}
worker: bundle exec sidekiq -q runner,default
