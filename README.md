# GitLab CI is an open-source continuous integration server

![Screen](https://github.com/downloads/gitlabhq/gitlab-ci/gitlab_ci_preview.png)


# Setup: 

## 1. Required packages:

    sudo apt-get update
    sudo apt-get upgrade

    sudo apt-get install -y wget curl gcc checkinstall libxml2-dev libxslt-dev libcurl4-openssl-dev libreadline6-dev libc6-dev libssl-dev libmysql++-dev make build-essential zlib1g-dev redis-server openssh-server git-core python-dev python-pip libyaml-dev postfix libpq-dev

    sudo pip install pygments


## 2. Install Ruby

    wget http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.3-p194.tar.gz
    tar xfvz ruby-1.9.3-p194.tar.gz
    cd ruby-1.9.3-p194
    ./configure
    make
    sudo make install


## 3. Get code 

    git clone https://github.com/gitlabhq/gitlab-ci.git

## 4. Setup application

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
    cp config/database.yml.example config/database.yml

    # Setup DB
    bundle exec rake db:setup


## 5. Run

    # For development 
    bundle exec foreman start -p 3000


    # For production
    bundle exec thin start -p 3000 -d -e production
    bundle exec rake environment resque:work RAILS_ENV=production PIDFILE=./resque.pid BACKGROUND=yes QUEUE=runner 


## 6. Login

    admin@local.host # email
    5iveL!fe # password
