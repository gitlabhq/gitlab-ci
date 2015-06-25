### Test and Deploy Python application to Heroku
Example Python application with tests on PostgreSQL database, staging and production deployment to Heroku can be found here:
[source](https://gitlab.com/ayufan/python-getting-started) and here: [ci](https://ci.gitlab.com/projects/4080)

### Configure project
This is how the configuration (the `.gitlab-ci.yml`) for that project looks like:
```yaml
test:
  script:
  # this configures django application to use attached postgres database that is run on `postgres` host
  - export DATABASE_URL=postgres://postgres:@postgres:5432/python-test-app
  - apt-get update -qy
  - apt-get install -y python-dev python-pip
  - pip install -r requirements.txt
  - python manage.py test

staging:
  type: deploy
  script:
  - apt-get update -qy
  - apt-get install -y ruby-dev
  - gem install dpl
  - dpl --provider=heroku --app=gitlab-ci-python-test-staging --api-key=$HEROKU_STAGING_API_KEY
  only:
  - master

production:
  type: deploy
  script:
  - apt-get update -qy
  - apt-get install -y ruby-dev
  - gem install dpl
  - dpl --provider=heroku --app=gitlab-ci-python-test-prod --api-key=$HEROKU_PRODUCTION_API_KEY
  only:
  - tags
```

This project have three jobs:
1. `test` - used to test rails application,
2. `staging` - used to automatically deploy staging environment every push to `master` branch
3. `production` - used to automatically deploy production environmnet for every created tag

### Store API keys
The project requires to create two secure variables in `Project > Variables`:
1. `HEROKU_STAGING_API_KEY` - Heroku API key used to deploy staging app,
2. `HEROKU_PRODUCTION_API_KEY` - Heroku API key used to deploy production app.

Heroku API key can be found in [Manage Account](https://dashboard.heroku.com/account).

### Create Heroku application
You have to navigate to Heroku [Dashboard](https://dashboard.heroku.com/) and create new application to each of your environments.

### Create runner
To build this project you also need to have `Runner`. You can use public runners available on `ci.gitlab.com`, but you can also provide your own:
```
gitlab-ci-multi-runner register \
  --non-interactive \
  --url "https://ci.gitlab.com/" \
  --registration-token "PROJECT_REGISTRATION_TOKEN" \
  --description "python-3.2" \
  --executor "docker" \
  --docker-image python:3.2 \
  --docker-postgres latest
```

Above command creates runner that uses `docker` (you need to have Docker installed), uses [python:3.2](https://registry.hub.docker.com/u/library/python/) image and uses [postgres](https://registry.hub.docker.com/u/library/postgres/) database.

To access PostgreSQL database you need to connect to `host: postgres` instead of default: `localhost` as `postgres` user without password.
