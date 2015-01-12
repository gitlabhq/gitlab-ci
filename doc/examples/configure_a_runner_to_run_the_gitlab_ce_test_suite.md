## Configure a runner to run the GitLab CE test suite

This prepares a runner to test GitLab CE. The actual [build script](build_script_gitlab_ce.md) is separate.

### 1. Set up the CI runner

```
# Ubuntu 14.04
wget https://s3-eu-west-1.amazonaws.com/downloads-packages/ubuntu-14.04/gitlab-runner_5.1.0~pre.omnibus.1-1_amd64.deb
# Ubuntu 12.04:
# wget https://s3-eu-west-1.amazonaws.com/downloads-packages/ubuntu-12.04/gitlab-runner_5.1.0~pre.omnibus.1-1_amd64.deb

sudo dpkg -i gitlab-runner_5.1.0~pre.omnibus.1-1_amd64.deb
sudo useradd -r -m gitlab-runner -s /bin/false

# This step is interactive; you need to enter the Coordinator URL and runner token
sudo /opt/gitlab-runner/bin/setup -C /home/gitlab-runner

sudo cp /opt/gitlab-runner/doc/install/upstart/gitlab-runner.conf /etc/init/
sudo service gitlab-runner start
```


### 2. Install ruby-build and Ruby 2.1.5

```bash
sudo apt-get install -y g++ gcc make libc6-dev libreadline6-dev zlib1g-dev \
  libssl-dev libyaml-dev libsqlite3-dev sqlite3 autoconf libgdbm-dev \
  libncurses5-dev automake libtool bison pkg-config libffi-dev git-core

sudo -Hu gitlab-runner sh <<EOF
set -e # abort if something fails
git clone https://github.com/sstephenson/ruby-build.git ~/ruby-build
cd ~/ruby-build
PREFIX=~ ./install.sh
cd ~
# This takes a while, compiling ruby from source
bin/ruby-build 2.1.5 ~
EOF
```

### 3. Packages for GitLab tests

```bash
sudo apt-get update
sudo apt-get install -y libicu-dev nodejs fontconfig cmake libkrb5-dev redis-server
```


### 4. MySQL

```bash
# This is an interactive command; you need to set the MySQL root password
sudo apt-get install -y mysql-server mysql-client libmysqlclient-dev

# This is an interactive command, you need to enter the MySQL root password
mysql -u root -p <<EOF
CREATE USER 'runner'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON * . * TO 'runner'@'localhost';
FLUSH PRIVILEGES;
EOF
```

### 5. Phantomjs

```bash
sudo -Hu gitlab-runner sh <<EOF
set -e # abort phantomjs installation on errors
cd ~
# x86-64 download command
wget http://phantomjs.googlecode.com/files/phantomjs-1.8.1-linux-x86_64.tar.bz2
tar -xjf phantomjs-1.8.1-linux-x86_64.tar.bz2
mv phantomjs-1.8.1-linux-x86_64 phantomjs
# end x86-64 download command
mkdir -p ~/bin
ln -s ~/phantomjs/bin/phantomjs ~/bin/
EOF

# should say '1.8.1'
sudo -Hu gitlab-runner bash -l -c '~/bin/phantomjs --version'
```

Done!

On i686, you can use the following download commands instead:

```
sudo -Hu gitlab-runner sh <<EOF
wget -P ~/app http://phantomjs.googlecode.com/files/phantomjs-1.8.1-linux-i686.tar.bz2
tar -xf phantomjs-1.8.1-linux-i686.tar.bz2
mv phantomjs-1.8.1-linux-i686 phantomjs
EOF
```
