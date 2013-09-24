# GitLab CI is an open-source continuous integration server

* [![build status](https://secure.travis-ci.org/gitlabhq/gitlab-ci.png)](https://travis-ci.org/gitlabhq/gitlab-ci)
* [![Code Climate](https://codeclimate.com/github/gitlabhq/gitlab-ci.png)](https://codeclimate.com/github/gitlabhq/gitlab-ci)
* [![Dependency Status](https://gemnasium.com/gitlabhq/gitlab-ci.png)](https://gemnasium.com/gitlabhq/gitlab-ci)
* [![Coverage Status](https://coveralls.io/repos/gitlabhq/gitlab-ci/badge.png?branch=master)](https://coveralls.io/r/gitlabhq/gitlab-ci)

![Screen](https://github.com/downloads/gitlabhq/gitlab-ci/gitlab_ci_preview.png)

### Requirements

GitLab CI officially supports (recent versions of) these Linux distributions:

* Ubuntu Linux
* Debian/GNU Linux

Additionally GitLab CI requires:

* GitLab 6.0+
* ruby 1.9.3
* MySQL or PostgreSQL

__If you want to use GitLab CI without GitLab or with older versions of GitLab you need to use [2-2-stable](https://github.com/gitlabhq/gitlab-ci/tree/2-2-stable#gitlab-ci-is-an-open-source-continuous-integration-server)__

### Limitations

The following features are not in GitLab CI but merge requests are very welcome:

* Email notification
* API documentation
* Increase test coverage (the goal is to be above 85%)
* Build artifacts access
* Build pipeline / build promotion actions

### Architecture

__GitLab CI__ is a web application with an API and it connect to the db.
It manage projects/builds and provides a nice user interface.
It uses the GitLab application API to authenticate users.

__GitLab CI Runner__ is a pure ruby application which processes builds.
It can be deployed separately and works with GitLab CI through an API.

In order to run tests you need at least 1 __GitLab CI__ instance and 1 __GitLab CI Runner__.
However, for running several builds at the same time you may want to setup more than one __GitLab CI Runner__.

Possible Cases: 

* 1 __GitLab CI__ and N __GitLab CI Runner__ instances on same machine
* 1 __GitLab CI__ and N __GitLab CI Runner__ instances on different machines
* 1 __GitLab CI__ and N __GitLab CI Runner__ instances on local machines

![screen](https://raw.github.com/gitlabhq/gitlab-ci/master/app/assets/images/arch.jpg)

For more information see:
[Announcing GitLab CI 3.0](http://blog.gitlab.org/announcing-gitlab-ci-3.0/)
and
[Integrating GitLab CI With GitLab to Enable Distributed Builds](http://blog.gitlab.org/integrating-gitlab-ci-with-gitlab/)

### Installation

* [Installation guide](https://github.com/gitlabhq/gitlab-ci/blob/master/doc/installation.md)

### How to add a new project to GitLab CI

1. Log in the GitLab CI web interface
2. Press the 'Sync now' button
3. Select your project with the 'Add' button
4. Go the the Integration page and do the 'Complete (as service)' steps
5. Go to the settings page to add a build script (see below for an example)
6. Push a new commit to the project
7. If the build fails then adjust the build script and press the 'Retry' button on the build page
8. If the build is green you are done, all new commits will be tested and you see the status of merge requests builds within GitLab

For your information, the runner runs the line below before it runs the commands in your build script:

    cd /gitlab-ci-runner/tmp/builds && git clone git@gitlab_server_fqdn:group/project.git project-1 && cd project-1 && git checkout master

Build script example:

    bundle install
    bundle exec rake db:create RAILS_ENV=test
    bundle exec rake db:migrate RAILS_ENV=test
    script/run_all_tests

### Getting help

* [Feedback and suggestions forum](http://feedback.gitlab.com/forums/176466-general/category/64310-gitlab-ci) is the place to propose and discuss new features for GitLab CI.
