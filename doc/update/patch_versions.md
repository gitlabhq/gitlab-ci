# Universal update guide for patch versions. For example from 4.0.0 to 4.0.1, also see the [semantic versioning specification](http://semver.org/).

### 1. stop CI server

    sudo service gitlab_ci stop

### 2. Switch to your gitlab_ci user

```
sudo su gitlab_ci
cd /home/gitlab_ci/gitlab-ci
```

### 3. get latest code

```
git pull origin STABLE_BRANCH
```

### 4. Install libs, migrations etc

```
bundle install --without development test --deployment
bundle exec rake db:migrate RAILS_ENV=production
```

### 5. Start web application

    sudo service gitlab_ci start
