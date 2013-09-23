# Setup: 

## 1. Packages / Dependencies

`sudo` is not installed on Debian by default. Make sure your system is
up-to-date and install it.

    sudo apt-get update
    sudo apt-get upgrade

**Note:**
Vim is an editor that is used here whenever there are files that need to be
edited by hand. But, you can use any editor you like instead.

    # Install vim
    sudo apt-get install -y vim

Install the required packages:

    sudo apt-get install -y wget curl gcc checkinstall libxml2-dev libxslt-dev libcurl4-openssl-dev libreadline6-dev libc6-dev libssl-dev libmysql++-dev make build-essential zlib1g-dev openssh-server git-core libyaml-dev postfix libpq-dev libicu-dev
    sudo apt-get install redis-server 

# 2. Ruby

Download Ruby and compile it:

    mkdir /tmp/ruby && cd /tmp/ruby
    curl --progress http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.3-p392.tar.gz | tar xz
    cd ruby-1.9.3-p392
    ./configure
    make
    sudo make install

Install the Bundler Gem:

    sudo gem install bundler --no-ri --no-rdoc


## 3. GitLab CI user:

    sudo adduser --disabled-login --gecos 'GitLab CI' gitlab_ci


## 4. Prepare the database

You can use either MySQL or PostgreSQL.

### MySQL

    # Install the database packages
    sudo apt-get install -y mysql-server mysql-client libmysqlclient-dev

    # Login to MySQL
    $ mysql -u root -p

    # Create the GitLab CI database
    mysql> CREATE DATABASE IF NOT EXISTS `gitlab_ci_production` DEFAULT CHARACTER SET `utf8` COLLATE `utf8_unicode_ci`;

    # Create the MySQL User change $password to a real password
    mysql> CREATE USER 'gitlab_ci'@'localhost' IDENTIFIED BY '$password';

    # Grant proper permissions to the MySQL User
    mysql> GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON `gitlab_ci_production`.* TO 'gitlab_ci'@'localhost';
    
    # Logout MYSQL
    mysql> exit;
    
### PostgreSQL

    # Install the database packages
    sudo apt-get install -y postgresql-9.1 libpq-dev

    # Login to PostgreSQL
    sudo -u postgres psql -d template1

    # Create a user for GitLab. (change $password to a real password)
    template1=# CREATE USER gitlab_ci WITH PASSWORD '$password';

    # Create the GitLab production database & grant all privileges on database
    template1=# CREATE DATABASE gitlab_ci_production OWNER gitlab_ci;

    # Quit the database session
    template1=# \q

    # Try connecting to the new database with the new user
    sudo -u gitlab_ci -H psql -d gitlab_ci_production

## 5. Get code 

    cd /home/gitlab_ci/

    sudo -u gitlab_ci -H git clone https://github.com/gitlabhq/gitlab-ci.git

    cd gitlab-ci

## 6. Setup application

    # Edit application settings
    sudo -u gitlab_ci -H cp config/application.yml.example config/application.yml
    sudo -u gitlab_ci -H vim config/application.yml

    # Edit web server settings
    sudo -u gitlab_ci -H cp config/puma.rb.example config/puma.rb
    sudo -u gitlab_ci -H vim config/puma.rb

    # Create socket and pid directories
    sudo -u gitlab_ci -H mkdir -p tmp/sockets/
    sudo chmod -R u+rwX  tmp/sockets/
    sudo -u gitlab_ci -H mkdir -p tmp/pids/
    sudo chmod -R u+rwX  tmp/pids/

### Install gems
 
    # For MySQL (note, the option says "without ... postgres")
    sudo -u gitlab_ci -H bundle install --without development test postgres --deployment

    # Or for PostgreSQL (note, the option says "without ... mysql")
    sudo -u gitlab_ci -H bundle install --without development test mysql --deployment

### Setup db

    # mysql
    sudo -u gitlab_ci -H cp config/database.yml.mysql config/database.yml

    # postgres
    sudo -u gitlab_ci -H cp config/database.yml.postgresql config/database.yml
 
    # Edit user/password
    sudo -u gitlab_ci -H vim config/database.yml

    # Setup tables
    sudo -u gitlab_ci -H bundle exec rake db:setup RAILS_ENV=production
    

    # Setup schedules
    #
    sudo -u gitlab_ci -H bundle exec whenever -w RAILS_ENV=production
   

## 7. Install Init Script

Copy the init script (will be /etc/init.d/gitlab_ci):

    sudo cp /home/gitlab_ci/gitlab-ci/lib/support/init.d/gitlab_ci /etc/init.d/gitlab_ci
    sudo chmod +x /etc/init.d/gitlab_ci

Make GitLab start on boot:

    sudo update-rc.d gitlab_ci defaults 21


Start your GitLab instance:

    sudo service gitlab_ci start
    # or
    sudo /etc/init.d/gitlab_ci restart


# 8. Nginx


## Installation
    sudo apt-get install nginx

## Site Configuration

Download an example site config:

    sudo cp /home/gitlab_ci/gitlab-ci/lib/support/nginx/gitlab_ci /etc/nginx/sites-available/gitlab_ci
    sudo ln -s /etc/nginx/sites-available/gitlab_ci /etc/nginx/sites-enabled/gitlab_ci

Make sure to edit the config file to match your setup:

    # Change **YOUR_SERVER_IP** and **YOUR_SERVER_FQDN**
    # to the IP address and fully-qualified domain name
    # of your host serving GitLab CI
    sudo vim /etc/nginx/sites-enabled/gitlab_ci

## Reload configuration

    sudo /etc/init.d/nginx reload



# 9. Runners


Now you need Runners to process your builds.
Checkout [runner repository](https://github.com/gitlabhq/gitlab-ci-runner#installation) for setup info.

# Done!


Visit YOUR_SERVER for your first GitLab CI login.
You should use your GitLab credentials in order to login

**Enjoy!**
