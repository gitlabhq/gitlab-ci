Build script to run the tests of GitLab CE
=================================

# Build script used at ci.gitlab.org to test the private GitLab B.V. repo at dev.gitlab.org

This build script can run both with the docker or shell executor in [gitlab-ci-multi-runner](https://gitlab.com/gitlab-org/gitlab-ci-multi-runner).

If you are using a shell executor, runner must be configured to have mysql and ruby, see a [configuration example](https://gitlab.com/gitlab-org/gitlab-ci/blob/master/doc/examples/configure/ruby.md).

```bash
if [ -f /.dockerinit ]; then
    wget -q http://ftp.de.debian.org/debian/pool/main/p/phantomjs/phantomjs_1.9.0-1+b1_amd64.deb
    dpkg -i phantomjs_1.9.0-1+b1_amd64.deb

    apt-get update -qq
    apt-get install -y -qq libicu-dev libkrb5-dev cmake nodejs

    cp config/database.yml.mysql config/database.yml
    sed -i 's/username:.*/username: root/g' config/database.yml
    sed -i 's/password:.*/password:/g' config/database.yml
    sed -i 's/# socket:.*/host: postgres/g' config/database.yml

    cp config/resque.yml.example config/resque.yml
    sed -i 's/localhost/redis/g' config/resque.yml
    FLAGS=(--deployment --path /cache)
else
    export PATH=$HOME/bin:/usr/local/bin:/usr/bin:/bin
    cp config/database.yml.mysql config/database.yml
    sed "s/username\:.*$/username\: runner/" -i config/database.yml
    sed "s/password\:.*$/password\: 'password'/" -i config/database.yml
    sed "s/gitlabhq_test/gitlabhq_test_$((RANDOM/5000))/" -i config/database.yml
fi

ruby -v
which ruby
gem install bundler --no-ri --no-rdoc

cp config/gitlab.yml.example config/gitlab.yml
touch log/application.log
touch log/test.log

bundle install --without postgres production --jobs $(nproc)  "${FLAGS[@]}"
RAILS_ENV=test bundle exec rake db:create
RAILS_ENV=test SIMPLECOV=true bundle exec rake test
```

# Build script on [GitHost.io](https://gitlab-ce.githost.io/projects/4/) to test the [GitLab.com repo](https://gitlab.com/gitlab-org/gitlab-ce)

```bash
# Install dependencies: phantomjs, redis, cmake
if [ ! -f ~/.runner_setup ]; then
    echo "Setting up runner"
    sudo wget https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-1.9.7-linux-x86_64.tar.bz2
    sudo tar xjf phantomjs-1.9.7-linux-x86_64.tar.bz2
    sudo mv phantomjs-1.9.7-linux-x86_64/bin/phantomjs /usr/local/bin/phantomjs
    sudo apt-get update
    sudo apt-get -y -q install mysql-server redis-server build-essential cmake curl
    touch ~/.runner_setup
    echo "Done setting up runner"
fi

# Install ruby
\curl -sSL https://get.rvm.io | bash -s stable --ruby
source ~/.rvm/scripts/rvm

# Prepare GitLab and run tests
ruby -v
gem install bundler
bundle install
cp config/database.yml.mysql config/database.yml
cp config/gitlab.yml.example config/gitlab.yml
RAILS_ENV=test bundle exec rake db:drop db:create
RAILS_ENV=test bundle exec rake test
```

# Troubleshooting

## InvalidByteSequenceError

Test pass locally but on CI there is an error with encoding.
One of the possible solutions for error: `Encoding::InvalidByteSequenceError: "\xF0" on US-ASCII` during build is setting the correct locale in the build job:

```
export LC_CTYPE=en_US.UTF-8

```

or

```
export LANG=en_US.UTF-8
```

