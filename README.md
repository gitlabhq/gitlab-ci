## 1. Setup

    # bundle

    # Login to MySQL
    $ mysql -u root -p

    # Create the GitLab CI database
    mysql> CREATE DATABASE IF NOT EXISTS `gitlab_ci_production` DEFAULT CHARACTER SET `utf8` COLLATE `utf8_unicode_ci`;

    # Create the MySQL User change $password to a real password
    mysql> CREATE USER 'gitlab_ci'@'localhost' IDENTIFIED BY '$password';

    # Grant proper permissions to the MySQL User
    mysql> GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON `gitlab_ci_production`.* TO 'gitlab_ci'@'localhost';


    # Copy config file
    cp config/application.yml.example config/application.yml

    # Setup DB
    bundle exec rake db:migrate


## 2. Run

    # For development 
    bundle exec foreman start -p 5000


    # For production
    bundle exec thin start -p 3000 -d -e production
    bundle exec rake environment resque:work RAILS_ENV=production PIDFILE=./resque.pid BACKGROUND=yes QUEUE=runner 
    
