mkdir -p tmp/pids
nohup bundle exec rake environment resque:work QUEUE=runner,scheduler_task VVERBOSE=1 RAILS_ENV=development PIDFILE=tmp/pids/resque_worker.pid > ./log/resque.log  &
nohup bundle exec rake environment resque:scheduler VVERBOSE=1 RAILS_ENV=development PIDFILE=tmp/pids/resque_schedule.pid > ./log/schedule.log  &
