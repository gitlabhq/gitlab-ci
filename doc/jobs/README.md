# Jobs
Jobs are user shell scripts. On each push to the GitLab the CI creates builds for each jobs. Every build will be served by runners where user shell script from job will be performed. There are two types of job: test (run in parallel) and deploy (run on success).

### Test job (run in parallel)

![Jobs](job.png)

This kind of jobs run in parallel and it can be usefull for test suite. For example, to saving your time you can run one part of suite in one build and second part in another build.
Fields:

`name` - an arbitrary name of job

`builds commit` (checkbox) - it should be checked if you want to create build when regular commit or branch is pushed.

`build tag` (checkbox) - it should be checked if you want to create build when tag is pushed.

_For example in GitLab, we created job for building packages. And we want this packages to be builded when we push new tag. In this case we disabled `builds commit` and enabled `build tag`._

`tags` - the list of tags (ex. "ruby mysql silenium"), only runner which contains the same set of tags can perform this build.
Script - shell script. Example for rails projects:

```
export PATH=~/bin:/usr/local/bin:/usr/bin:/bin
gem install bundler 
cp config/database.yml.mysql config/database.yml
cp config/application.yml.example config/application.yml
bundle
RAILS_ENV=test bundle exec rake db:setup 
RAILS_ENV=test bundle exec rake spec
```


### Deploy job (run on success)

![Deploy jobs](deploy_job.png)

This type of jobs runs after all test jobs succeded. It is usefull for deploy. For example, you want to make sure that whole test suite passes before deploy. Fields:

`name` - an arbitrary name of job

`tags` - If you want to only one runner could run deploy you can rich it by setting appropriate tags. It can be usefull because most likely you will need to grant runner with special permissions.

`refs` - You can specify git refs which should trigger deploy job

`script` - Shell script to run.

