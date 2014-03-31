Build script to run the tests of GitLab CE
=================================

This script can be run to tests of GitLab CE on a [configured](configure_a_runner_to_run_the_gitlab_ce_test_suite.md) runner.

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
bundle exec rake gitlab:test RAILS_ENV=test 
```
