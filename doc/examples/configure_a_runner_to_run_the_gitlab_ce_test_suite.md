## Configure a runner to run the GitLab CE test suite

This prepares a runner to test GitLab CE. The actual [build script](build_script_gitlab_ce.md) is separate.

### 1. packages

```bash
sudo apt-get install -y build-essential zlib1g-dev libyaml-dev libssl-dev libgdbm-dev libreadline-dev libncurses5-dev libffi-dev curl openssh-server redis-server checkinstall libxml2-dev libxslt-dev libcurl4-openssl-dev libicu-dev logrotate
```

### 2. ruby

```bash
\curl -L https://get.rvm.io | bash -s stable --ruby
```

### 3. runner

```bash
# Use any directory you like
mkdir ~/gitlab-runners
cd ~/gitlab-runners
git clone https://github.com/gitlabhq/gitlab-ci-runner.git
cd gitlab-ci-runner
gem install bundler
bundle install
bundle exec ./bin/setup
nohup bundle exec ./bin/runner &
```


### 4. mysql

```bash

$ sudo apt-get install -y mysql-server mysql-client libmysqlclient-dev

$ mysql -u root -p

mysql> CREATE USER 'runner'@'localhost' IDENTIFIED BY 'password';
Query OK, 0 rows affected (0.00 sec)

mysql> GRANT ALL PRIVILEGES ON * . * TO 'runner'@'localhost';
Query OK, 0 rows affected (0.00 sec)

mysql> FLUSH PRIVILEGES;
Query OK, 0 rows affected (0.00 sec)

```

### 5. phantomjs

```bash
mkdir ~/app/
cd ~/app

# x64
wget -P ~/app http://phantomjs.googlecode.com/files/phantomjs-1.8.1-linux-x86_64.tar.bz2
tar -xf phantomjs-1.8.1-linux-x86_64.tar.bz2
mv phantomjs-1.8.1-linux-x86_64 phantomjs

# x86
wget -P ~/app http://phantomjs.googlecode.com/files/phantomjs-1.8.1-linux-i686.tar.bz2
tar -xf phantomjs-1.8.1-linux-i686.tar.bz2
mv phantomjs-1.8.1-linux-i686 phantomjs

# all version
sudo apt-get install fontconfig
sudo ln -s ~/app/phantomjs/bin/phantomjs /usr/bin/phantomjs
phantomjs --version
```


### 6. misc

```bash
sudo adduser --disabled-login --gecos 'GitLab' git
```
