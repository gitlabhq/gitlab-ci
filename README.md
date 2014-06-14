## GitLab CI is an open-source continuous integration server

[![build status](https://ci.gitlab.org/projects/2/status.png?ref=master)](https://ci.gitlab.org/projects/2?ref=master)
[![Code Climate](https://codeclimate.com/github/gitlabhq/gitlab-ci.png)](https://codeclimate.com/github/gitlabhq/gitlab-ci)
[![Dependency Status](https://gemnasium.com/gitlabhq/gitlab-ci.png)](https://gemnasium.com/gitlabhq/gitlab-ci)
[![Coverage Status](https://coveralls.io/repos/gitlabhq/gitlab-ci/badge.png?branch=master)](https://coveralls.io/r/gitlabhq/gitlab-ci)

![Screen](https://gitlab.com/gitlab-org/gitlab-ci/raw/master/public/gitlab-ci-screenshot.png)

### Requirements

GitLab CI officially supports (recent versions of) these Linux distributions:

* Ubuntu Linux
* Debian/GNU Linux

Additionally GitLab CI requires:

* GitLab 6.3+ (to host the repositories you test)
* ruby 1.9.3
* MySQL or PostgreSQL

Hardware requirements:

* 1GB of memory or more is recommended, 512MB works
* 2 CPU cores or more are recommended, 1 CPU core works
* A little disk space, 100MB or less

## Features

* Single Sign On: use the same login and password as on your GitLab instance
* Quick project setup: add your project in a single click, all setup automatic via the GitLab API
* Elegant and flexible: build scripts are written in bash, test projects in any programming language
* Merge request integration: see the status of the feature branch build within the Merge Request
* Distributed by default: GitLab CI and build runners can run on separate machines providing more stability
* Realtime logging: the current build log scrolls and updates every few seconds

### Roadmap

The following features are not yet in GitLab CI but merge requests are very welcome:

* [Build artifacts access](http://feedback.gitlab.com/forums/176466-general/suggestions/4522830-allow-access-to-build-artifacts-of-gitlab-ci)
* For parallel builds, deployments, branch specific builds and build metrics there is a [blog article with implementation steps](http://blog.gitlab.org/gitlab-ci-with-parallel-builds-and-deployments/)

### Runners

To perform the actual build you need a CI runner (also see the Architecture section below):

* [Official CI runner for Linux](https://gitlab.com/gitlab-org/gitlab-ci-runner)
* [Unofficial CI runner for Windows](https://github.com/virtualmarc/gitlab-ci-runner-win)
* [Unofficial CI runner for Scala/Java](https://github.com/nafg/gitlab-ci-runner-scala)
* [Unofficial CI runner for Node](https://www.npmjs.org/package/gcr)

### Architecture

__GitLab CI__ is a web application with an API that stores its state in a databse.
It manages projects/builds and provides a nice user interface.
It uses the GitLab application API to authenticate users.

[GitLab CI Runner](https://github.com/gitlabhq/gitlab-ci-runner) is a pure ruby application which processes builds.
It can be deployed separately and works with GitLab CI through an API.

In order to run tests you need at least 1 __GitLab CI__ instance and 1 __GitLab CI Runner__.
However, for running several builds at the same time you may want to setup more than one __GitLab CI Runner__.

Possible Cases: 

* 1 __GitLab CI__ and N __GitLab CI Runner__ instances on same machine
* 1 __GitLab CI__ and N __GitLab CI Runner__ instances on different machines
* 1 __GitLab CI__ and N __GitLab CI Runner__ instances on local machines

![screen](https://gitlab.com/gitlab-org/gitlab-ci/raw/master/app/assets/images/arch.jpg)

For more information see:
[Announcing GitLab CI 3.0](http://blog.gitlab.org/announcing-gitlab-ci-3.0/)
and
[Integrating GitLab CI With GitLab to Enable Distributed Builds](http://blog.gitlab.org/integrating-gitlab-ci-with-gitlab/)

### Installation

* [Installation guide](doc/install/installation.md)

### How to add a new project to GitLab CI

1. Log in the GitLab CI web interface
1. Press the 'Sync now' button
1. Select your project with the 'Add' button
1. Go to the settings page of the project and add a build script (example given below)
1. A new build should become visible on the project page of GitLab CI
1. If the build fails then adjust the build script and press the 'Retry' button on the build page
1. If the build is green you are done, all new commits will be tested and you see the status of merge requests builds within GitLab

### Build script

For your information, the runner runs the line below before it runs the commands in your build script:

    cd /gitlab-ci-runner/tmp/builds && git clone git@gitlab_server_fqdn:group/project.git project-1 && cd project-1 && git checkout master

Build script example:

    bundle install
    bundle exec rake db:create RAILS_ENV=test
    bundle exec rake db:migrate RAILS_ENV=test
    script/run_all_tests

The build command is run from [GitlabCi::Build#command](https://gitlab.com/gitlab-org/gitlab-ci-runner/blob/master/lib/build.rb#L96) and contains the following environmental variables:

    CI_SERVER, CI_SERVER_NAME, CI_SERVER_VERSION, CI_SERVER_REVISION
    CI_BUILD_REF, CI_BUILD_BEFORE_SHA, CI_BUILD_REF_NAME (branch), CI_BUILD_ID

### Documentation

All documentation can be found on [doc.gitlab.com/ci/](http://doc.gitlab.com/ci/).

### Getting help

Please see [Getting help for GitLab](https://www.gitlab.com/getting-help/) on our website for the many options to get help.
