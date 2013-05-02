# Setup: 

Create a user for GitLab:

    sudo adduser --disabled-login --gecos 'GitLab CI' gitlab_ci


## 1. Required packages:

    sudo apt-get update
    sudo apt-get upgrade

    sudo apt-get install -y wget curl gcc checkinstall libxml2-dev libxslt-dev libcurl4-openssl-dev libreadline6-dev libc6-dev libssl-dev libmysql++-dev make build-essential zlib1g-dev openssh-server git-core libyaml-dev postfix libpq-dev libicu-dev
    sudo apt-get install redis-server 

## 2. Install Ruby (RVM) for gitlab_ci

    sudo su gitlab_ci

    \curl -L https://get.rvm.io | bash -s stable --ruby

    # Add next line to ~/.bashrc
    echo "source /home/gitlab_ci/.rvm/scripts/rvm" >> ~/.bashrc


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

    cd /home/gitlab_ci/

    sudo -u gitlab_ci -H git clone https://github.com/gitlabhq/gitlab-ci.git

    cd gitlab-ci

    # Checkout preferable version
    sudo -u gitlab_ci -H  git checkout 2-2-stable

## 5. Setup application

    # Act as gitlab_ci user
    #
    sudo su gitlab_ci
    cd ~/gitlab-ci

    # Create a tmp directory inside application
    #
    mkdir -p tmp/pids

    # Install dependencies
    #
    gem install bundler
    bundle --without development test

    # Copy mysql db config
    #
    # make sure to update username/password in config/database.yml
    #
    cp config/database.yml.mysql config/database.yml

    # Setup DB
    #
    bundle exec rake db:setup RAILS_ENV=production

    # Setup scedules 
    #
    bundle exec whenever -w RAILS_ENV=production
   
    # Now exit from gitlab_ci user
    exit


## 6. Install Init Script

Download the init script (will be /etc/init.d/gitlab_ci):

    sudo wget https://raw.github.com/gitlabhq/gitlab-ci/2-2-stable/lib/support/init.d/gitlab_ci -P /etc/init.d/
    sudo chmod +x /etc/init.d/gitlab_ci

Make GitLab start on boot:

    sudo update-rc.d gitlab_ci defaults 21


Start your GitLab instance:

    sudo service gitlab_ci start
    # or
    sudo /etc/init.d/gitlab_ci restart


# 7. Nginx


## Installation
    sudo apt-get install nginx

## Site Configuration

Download an example site config:

    sudo wget https://raw.github.com/gitlabhq/gitlab-ci/2-2-stable/lib/support/nginx/gitlab_ci -P /etc/nginx/sites-available/
    sudo ln -s /etc/nginx/sites-available/gitlab_ci /etc/nginx/sites-enabled/gitlab_ci

Make sure to edit the config file to match your setup:

    # Change **YOUR_SERVER_IP** and **YOUR_SERVER_FQDN**
    # to the IP address and fully-qualified domain name
    # of your host serving GitLab CI
    sudo vim /etc/nginx/sites-enabled/gitlab_ci

## Restart

    sudo /etc/init.d/nginx restart


# Done!


Visit YOUR_SERVER for your first GitLab CI login.
The setup has created an admin account for you. You can use it to log in:

    admin@local.host
    5iveL!fe

**Important Note:**
Please go over to your profile page and immediately change the password, so
nobody can access your GitLab CI by using this login information later on.

**Enjoy!**
