mkdir -p tmp/pids
nohup bundle exec rake environment resque:work QUEUE=runner,scheduler_task RAILS_ENV=production PIDFILE=tmp/pids/resque_worker.pid > ./log/resque.log  &
nohup bundle exec rake environment resque:scheduler RAILS_ENV=production PIDFILE=tmp/pids/resque_schedule.pid > ./log/schedule.log  &
