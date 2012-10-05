PIDFILE=./resque.pid BACKGROUND=yes QUEUE=* exec rake resque:work
