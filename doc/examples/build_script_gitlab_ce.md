Build script to run the tests of GitLab CE
=================================

These script can be run to tests of GitLab CE on a [configured](configure_a_runner_to_run_the_gitlab_ce_test_suite.md) runner.

# Build script used at ci.gitlab.org to test the private GitLab B.V. repo at dev.gitlab.org

```bash
ruby -v
gem install bundler
cp config/database.yml.mysql config/database.yml
cp config/gitlab.yml.example config/gitlab.yml
sed "s/username\:.*$/username\: runner/" -i config/database.yml
sed "s/password\:.*$/password\: 'password'/" -i config/database.yml
sed "s/gitlabhq_test/gitlabhq_test_$((RANDOM/5000))/" -i config/database.yml
touch log/application.log
touch log/test.log
bundle --without postgres
bundle exec rake test RAILS_ENV=test 
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
