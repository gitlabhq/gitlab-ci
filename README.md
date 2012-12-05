# GitLab CI is an open-source continuous integration server 
[![build status](https://secure.travis-ci.org/gitlabhq/gitlab-ci.png)](https://travis-ci.org/gitlabhq/gitlab-ci) [![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/gitlabhq/gitlab-ci)

![Screen](https://github.com/downloads/gitlabhq/gitlab-ci/gitlab_ci_preview.png)


# Requirements: 

**The project is designed for the Linux operating system.**

We officially support (recent versions of) these Linux distributions:

- Ubuntu Linux
- Debian/GNU Linux

__We recommend to use server with at least 756MB RAM for gitlab-ci instance.__


# Setup: 

## 1. Required packages:

    sudo apt-get update
    sudo apt-get upgrade

    sudo apt-get install -y wget curl gcc checkinstall libxml2-dev libxslt-dev libcurl4-openssl-dev libreadline6-dev libc6-dev libssl-dev libmysql++-dev make build-essential zlib1g-dev openssh-server git-core libyaml-dev postfix libpq-dev
    sudo apt-get install redis-server 

## 2. Install Ruby

    wget http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.3-p194.tar.gz
    tar xfvz ruby-1.9.3-p194.tar.gz
    cd ruby-1.9.3-p194
    ./configure
    make
    sudo make install


## 3. Prepare MySQL

    sudo apt-get install -y mysql-server mysql-client libmysqlclient-dev

    # Login to MySQL
    $ mysql -u root -p

    # Create the GitLab CI database
    mysql> CREATE DATABASE IF NOT EXISTS `gitlab_ci_production` DEFAULT CHARACTER SET `utf8` COLLATE `utf8_unicode_ci`;

    # Create the MySQL User change $password to a real password
    mysql> CREATE USER 'gitlab_ci'@'localhost' IDENTIFIED BY '$password';

    # Grant proper permissions to the MySQL User
    mysql> GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON `gitlab_ci_production`.* TO 'gitlab_ci'@'localhost';

## 4. Get code 

    git clone https://github.com/gitlabhq/gitlab-ci.git


## 5. Setup application


    # Install dependencies
    #
    sudo gem install bundler
    bundle

    # Copy mysql db config
    #
    # make sure to update username/password in config/database.yml
    #
    cp config/database.yml.mysql config/database.yml

    # Setup DB
    #
    bundle exec rake db:setup RAILS_ENV=production


## 6. Run

    # For development 
    bundle exec foreman start -p 3000

    # For production
    bundle exec thin start -p 3000 -d -e production
    bundle exec rake environment resque:work RAILS_ENV=production PIDFILE=./resque.pid BACKGROUND=yes QUEUE=runner 


## 7. Login

    admin@local.host # email
    5iveL!fe # password

## 8. Nginx


Setup nginx

   sudo apt-get install nginx
   sudo vim /etc/nginx/sites-enabled/gitlab_ci


Add config

    upstream gitlab_ci {
      server 127.0.0.1:3000;
    }

    server {
      listen 80;
      server_name ci.gitlabhq.com;

      root /home/gitlab_ci/gitlab-ci/public;
      try_files $uri $uri/index.html $uri.html @gitlab_ci;

      location @gitlab_ci {
        # auth_basic "Private Zone";
        # auth_basic_user_file htpasswd;

        proxy_set_header Host $host:$server_port;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Sendfile-Type X-Accel-Redirect;

        proxy_pass http://gitlab_ci;
      }
    }

