## Configuraton of your builds with .gitlab-ci.yaml

From version 7.12, GitLab CI uses a .gitlab-ci.yml file for the configuration of your builds. It is place in the root of your repository and contains four main sections: skep_refs, before_script, jobs and deploy_jobs. Here is an example of how it looks:

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
This parameter defines the ref or list of refs to skip. You can use glob pattern syntax as well. Example: "staging,feature-*"

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
you can also fill commands like an array:
```
- script:
  - bundle update
  - bundle exec rspec
```
And there is one more way to specify build configuration, using a string:
```
jobs:
- bundle exec rspec
```
In this way, the name of the build will be taken from command line.

## deploy_jobs
Deploy Jobs that will be run when all other jobs have succeeded. Define them using a hash:

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

You can also define deploy jobs with a string:

```
deploy_jobs:
-  "bundle exec cap deploy"
```

## before_script
`before_script` is used to define the command that should be ran before all builds, including deploy builds. This can be an array or a multiline string.