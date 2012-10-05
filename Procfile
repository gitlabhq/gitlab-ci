web: bundle exec thin start -p $PORT
worker: bundle exec rake resque:work QUEUE=* VVERBOSE=1
