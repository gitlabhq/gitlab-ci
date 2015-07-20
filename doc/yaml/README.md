# Configuration of your builds with .gitlab-ci.yml
From version 7.12, GitLab CI uses a [YAML](https://en.wikipedia.org/wiki/YAML) file (**.gitlab-ci.yml**) for the project configuration.
It is placed in the root of your repository and contains definition how project should be built.

The YAML defines set of jobs with constrains when they should be run.
The jobs are defined as top-level elements with name and always have to contain the `script`: 
```yaml
job1:
  script: "execute-script-for-job1"

job2:
  script: "execute-script-for-job2"
```

The above example is the simplest possible CI configuration with two separate jobs,
where each of the job executes different script.

Jobs are used to create builds, which are then picked by [runners](../runners/README.md) and executed within environment of the runner.
What is important that each job is run independently from each other. 

## .gitlab-ci.yml
The YAML syntax allows to use more complex jobs specification then above example:
```yaml
image: ruby:2.1
services:
  - postgres

before_script:
  - bundle_install

types:
  - build
  - test
  - deploy

job1:
  type: build
  script:
    - execute-script-for-job1
  only:
    - master
  tags:
    - docker
```

There are a few `keywords` that can't be used as job names:

| keyword       | required | description |
|---------------|----------|-------------|
| image         | optional | Use docker image, covered in [Use Docker](../docker/README.md) |
| services      | optional | Use docker services, covered in [Use Docker](../docker/README.md) |
| types         | optional | Define build types |
| before_script | optional | Define commands prepended for each job's script |

### image and services
This allows to specify custom Docker image and list of services that can be used for time of the build.
The configuration of this feature is covered in separate document: [Use Docker](../docker/README.md).

### before_script
`before_script` is used to define the command that should be ran before all builds, including deploy builds. This can be an array or a multiline string

### types
`types` is used to define build types that can be used by jobs.
The specification of `types` allow to have flexible multi stage pipeline. 

The ordering of elements in `types` defines the ordering of builds execution:

1. Builds of the same type are run in parallel. 
1. Builds of next type are run after success.

Let's consider following example that defines 3 types:
```
types:
  - build
  - test
  - deploy
```

1. First all jobs of `build` are executed in parallel.
1. If all jobs of `build` succeeds, the `test` jobs are executed in parallel.
1. If all jobs of `test` succeeds, the `deploy` jobs are executed in parallel.
1. If all jobs of `deploy` succeeds, the commit is marked as `success`.
1. If any of the previous jobs fails the commit is marked as `failed` and no jobs of further type is executed.

There are also two edge cases worth mentioning:

1. If no `types` is defined in `.gitlab-ci.yml` by default: build, test and deploy is allowed to be used as job's type.
2. If job doesn't specify `type`, the job is assigned to `test`.

## Jobs
`.gitlab-ci.yml` allows to specify unlimited number of jobs.
Each job has to have unique `job_name`, that is not the one of the keywords. 
Job is defined by a list of parameters that define the build behaviour.

```yaml
job_name:
  script:
    - rake spec
    - coverage
  type: test
  only:
    - master
  except:
    - develop
  tags:
    - ruby
    - postgres
  allow_failure: true
```

| keyword       | required | description |
|---------------|----------|-------------|
| script        | required | Defines a shell script which is executed by runner |
| type          | optional (default: test) | Defines a build type |
| only          | optional | Defines a list of git refs for which build is created |
| except        | optional | Defines a list of git refs for which build is not created |
| tags          | optional | Defines a list of tags which are used to select runner |
| allow_failure | optional | Allow build to fail. Failed build doesn't contribute to commit status |

### script
`script` is a shell script which is executed by runner. The shell script is prepended with `before_script`.

```yaml
job:
  script: "bundle exec rspec"
```

This parameter can also contain several commands using array:
```yaml
job:
  script:
    - uname -a
    - bundle exec rspec
```

### type
`type` allows to group build into different stages. Builds of the same `type` are executed in `parallel`.
For more info about the use of `type` please check the [types](#types).

### only and except
This are two parameters that allows to set refs policy to limit when jobs are built:
1. `only` defines the names of branches and tags for which job will be build.
2. `except` defines the names of branches and tags that will be excluded from building specific job.

There are a few rules that apply to usage of refs policy:

1. `only` and `except` are exclusive. If both `only` and `except` are defined in job specification only `only` is taken into account.
1. `only` and `except` allows to use the regexp expressions.
1. `only` and `except` allows to use special keywords: `branches` and `tags`.
These names can be used for example to exclude all tags and all branches.

```yaml
job:
  only:
    - /^issue-.*$/ # use regexp
  except:
    - branches # use special keyword
```

### tags
`tags` is used to select specific runner from the list of all runners that are allowed to run this project.

During registration of runner you can specify runner's tags, ie.: `ruby`, `postgres`, `development`.
`tags` allows you to run builds by runners that have the specified tags assigned:

```
job:
  tags:
    - ruby
    - postgres
```

The above specification will make sure that `job` is built by runner that have `ruby` AND `postgres` tags defined.

## Validate the .gitlab-ci.yml
Each instance of GitLab CI has an embedded debug tool Lint.
You can find the link to the Lint in the project's settings page or use short url `/lint`.

## Skipping builds
There is one more way to skip all builds, if your commit message contains tag [ci skip]. In this case, commit will be created but builds will be skipped
