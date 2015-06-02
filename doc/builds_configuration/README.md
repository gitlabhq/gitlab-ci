## Configuraton of your builds with .gitlab-ci.yaml

Sinse 7.12 version GitLab CI uses special yaml file for configuration your builds. This yaml file should be placed in the root of your repository and should be named as .gitlab-ci.yml. This file contains 4 main sections: skep_refs, before_script, jobs and deploy_jobs. Example of configuration file:

```
skip_refs: staging
before_script: |
  export PATH=$HOME/bin:/usr/local/bin:/usr/bin:/bin
  gem install bundler
  cp config/database.yml.mysql config/database.yml
  bundle install --without postgres production --jobs $(nproc)
  bundle exec rake db:create RAILS_ENV=test
jobs:
- script: "bundle exec rspec"
  name: Rspec
  runner: mysql,ruby
- "bundle exec cucumber" # or even so
deploy_jobs:
- "bundle exec cap deploy"

```

Let's have a close look at each section.

### skip_refs
This parameter defines ref or list of refs to skip. You can use glob pattern syntax as well. Example: "staging,feature-*"

### jobs
Here you can specify parameters of your builds. There are serveral ways you can configure it. Using hash:
```
jobs:
- script: "bundle exec rspec" # (required) - commands to run
  name: Rspec                 # (optional) - name of build
  runner: mysql,ruby          # (optional) - runner tags, only runners which have these tags will be used
  branches: true              # (optional) - make builds for regular branches
  tags: true                  # (optional) - make builds for tags
```
`script` can also cantain several commands using YAML multiline string:
```
- script: |
    bundle updata
    bundle exec rspec
```
you can also fill commands like array:
```
- script:
  - bundle update
  - bundle exec rspec
```
And there is one more way to specify build configuration, using string:
```
jobs:
- bundle exec rspec
```
In this way, name of build will be taken from this command line.

## deploy_jobs
Deploy Jobs define the builds that will be run when all job succedded. Define using hash:

```
deploy_jobs:
- script: |                             # (required) - command
    bundle update
    bundle exec cap deploy
  name: Deploy                          # (optional) - name
  refs: deploy                          # (optional) - run only when the above git refs strings match the branch or tag that was pushed.
  runner: ruby,deploy                   # (optional) - runner tags, only runners which have these tags will be used
```

`script` can be a multiline script or array like for regular jobs.

You can also define deploy jobs with string:

```
deploy_jobs:
-  "bundle exec cap deploy"
```

## before_script
This section is used for defining command that should be run before all builds, including deploy builds. Can be an array or multiline string.