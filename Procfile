web: bundle exec rails s -p $PORT
worker: bundle exec rake environment resque:work QUEUE=runner,scheduler_task VVERBOSE=1
schedule: bundle exec rake environment resque:scheduler VVERBOSE=1 RAILS_ENV=development
