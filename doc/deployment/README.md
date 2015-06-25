## GitLab-CI deployment

GitLab-CI support deployment builds. Deploy Builds that are ran when all other builds have succeeded. This builds can be defined using simple syntax:

```yaml
production:
  type: deploy
  script:
  - prepare-for-deploy
  - deploy-to-service
```

## Use Travis-CI deployment tool
We recommend to use **Dpl**. Dpl (dee-pee-ell) is a deploy tool made for continuous deployment that's developed and used by Travis CI, but can also be used with GitLab CI. You can read more information about it here: https://github.com/travis-ci/dpl.

### Requirements
To use `dpl` you need `ruby` at least 1.8.7 with ability to install `gems`.

### Installation
The `dpl` can be installed on any machine with:
```
gem install dpl
```

If you don't have Ruby installed you can do it on `Debian-compatible` `Linux` with:
```
apt-get update
apt-get install ruby-dev
```

What is also nice about `Dpl` is that you can install it on your computer and test all the commands from your Terminal without the need to test it on `CI` server.

### How to use it?
The `dpl` provides support for vast number of services, including: Heroku, Cloud Foundry, AWS/S3, and more. To use it simply define provider and any additional parameters required by the provider.

For example if you want to use it to deploy your application to heroku, you need to specify `heroku` as provider, specify `api-key` and `app`. There's more and all possible parameters can be found here: https://github.com/travis-ci/dpl#heroku

```
staging:
  type: deploy
  - gem install dpl
  - dpl --provider=heroku --app=my-app-staging --api-key=$HEROKU_STAGING_API_KEY
```

In the above example we use `dpl` to deploy `my-app-staging` to Heroku server with api-key stored in `HEROKU_STAGING_API_KEY` secure variable.

### Use different provider
Tu use different provider take a look at long list of [Supported Providers](https://github.com/travis-ci/dpl#supported-providers).

### How to use it to have staging and production environment?
It's pretty common in developer workflow to have staging (-dev) and production environment. If we consider above example: we would like to deploy `master` branch to `staging` and `all tags` to `production environment`. The final `.gitlab-ci.yml` for such setup would look like this:

```
staging:
  type: deploy
  - gem install dpl
  - dpl --provider=heroku --app=my-app-staging --api-key=$HEROKU_STAGING_API_KEY
  only:
  - master
  
production:
  type: deploy
  - gem install dpl
  - dpl --provider=heroku --app=my-app-production --api-key=$HEROKU_PRODUCTION_API_KEY
  only:
  - tags
```

We basically created two deploy jobs that are execute for different events:
1. `staging` is executed for all commits that were pushed to `master` branch,
2. `production` is executed for all pushed tags.

We also use two secure variables:
1. `HEROKU_STAGING_API_KEY` - Heroku API key used to deploy staging app,
2. `HEROKU_PRODUCTION_API_KEY` - Heroku API key used to deploy production app.

### The way to store API keys?
In GitLab CI 7.12 a new feature was introduced: Secure Variables. Secure Variables can added by going to `Project > Variables > Add Variable`. **This feature requires `gitlab-runner` with version equal or greater than 0.4.0.** The variable defined in project settings are send with build script to runner and set before executing script. What is important that such variable is stored outside of the project's repository. You should never store secrets in your project's `.gitlab-ci.yml`!  What is also important that it's value is hidden in the build log.

You access added variable by prefixing it's name with `$` (on non-Windows runners) or `%` (for Windows Batch runners):
1. `$SECRET_VARIABLE` - use it for non-Windows runners
2. `%SECRET_VARIABLE%` - use it for Windows Batch runners

### Using `dpl` with `Docker`
When you use `runner` you most likely configured it to use your server's shell commands. This means that all commands are run in context of local user (ie. gitlab_runner or gitlab_ci_multi_runner). It also means that most probably in your `Docker` container you don't have the `Ruby` runtime. You have to install it:
```
staging:
  type: deploy
  - apt-get update -yq
  - apt-get install -y ruby-dev
  - gem install dpl
  - dpl --provider=heroku --app=my-app-staging --api-key=$HEROKU_STAGING_API_KEY
  only:
  - master
```

The first line `apt-get update -yq` updates the list of available packages, where second `apt-get install -y ruby-dev` install `Ruby` runtime on system. The above example is valid for all Debian-compatible systems.
