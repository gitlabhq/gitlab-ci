## Configuraton of your builds with .gitlab-ci.yml

From version 7.12, GitLab CI uses a .gitlab-ci.yml file for the configuration of your builds. It is placed in the root of your repository and contains three type of objects: before_script, builds and deploy_builds. Here is an example of how it looks:

```yaml
before_script: 
  - gem install bundler
  - bundle install 
  - bundle exec rake db:create

rspec: 
  script: "rake spec"
  tags: 
    - ruby
    - postgres
  only: 
    - branches

staging: 
  script: "cap deploy stating"
  type: deploy
  tags: 
    - capistrano
    - debian
  except:
    - stable
    - /^deploy-.*$/

```

Let's have a close look at each section.

### builds
Here you can specify parameters of your builds:

```yaml
rspec: 
  script: "rake spec"  # (required) - shell command for runner
  tags:                # (optional) - runner tags, only runners which have these tags will be used
    - ruby
    - postgres
  only:                # (optional) - git refs (branches and tags)
    - master

```

`rspec` is a key of this object and it determines the name of your build

`script` is a shell script which is used by runner. It will be also prepanded with `before_script`. This parameter can also cantain several commands using array:

```yaml
script:
  - uname -a
  - bundle exec rspec
```
About `only` and `except` parameters you can read in the [refs settings explanation](#refs-settings-explanation)

### deploy_builds
Deploy Builds that will be run when all other builds have succeeded. Define them using simple syntax:

```yaml
production: 
  script: "cap deploy production" # (required) - shell command for runner
  type: deploy
  tags: 
    - ruby
    - postgres
  only:
    - master
```
`production` - is a name of deploy build.
`script` - is a shell script which will be prepended with `before_script`.
`type: deploy` is a parameter which indicates that it is a deploy job
About `only` and `except` parameters you can read in the [refs settings explanation](#refs-settings-explanation)

### before_script
`before_script` is used to define the command that should be ran before all builds, including deploy builds. This can be an array or a multiline string.

### Refs settings explanation
There are two parameters that help you to set up refs policy for your build or deploy build on CI.
```
only:
  - master
```
`only` defines exact name of the branch or the tag which will be run. It also supports the regexp expressions:

```
only:
  - /^issue-.*$/
```
You can also use an `except` parameter:
```
except:
  - "deploy"
```
This parameter is used for excluding some refs. It is also supporting regexp expressions.

There are also special keys like `branches` or `tags`. These parameters can be used for excluding all tags or branches.
```
except:
  - branches
```

## Debugging of your builds with .gitlab-ci.yml

Each instance of GitLab CI has an embeded debug tool Lint. You can find link to the Lint in the projects settings page or use short url `/lint`.

## Skipping builds
There is one more way to skip all builds, if your commit message contains tag [ci skip]. In this case commit will be created but builds will be skipped.
