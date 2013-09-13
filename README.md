# GitLab CI is an open-source continuous integration server

* [![build status](https://secure.travis-ci.org/gitlabhq/gitlab-ci.png)](https://travis-ci.org/gitlabhq/gitlab-ci)
* [![Code Climate](https://codeclimate.com/github/gitlabhq/gitlab-ci.png)](https://codeclimate.com/github/gitlabhq/gitlab-ci)
* [![Dependency Status](https://gemnasium.com/gitlabhq/gitlab-ci.png)](https://gemnasium.com/gitlabhq/gitlab-ci)
* [![Coverage Status](https://coveralls.io/repos/gitlabhq/gitlab-ci/badge.png?branch=master)](https://coveralls.io/r/gitlabhq/gitlab-ci)

![Screen](https://github.com/downloads/gitlabhq/gitlab-ci/gitlab_ci_preview.png)

### Requirements

GitLab CI is designed for the Linux operating system.

GitLab CI officially supports (recent versions of) these Linux distributions:

* Ubuntu Linux
* Debian/GNU Linux

Additionally GitLab CI requires:

* ruby 1.9.3
* MySQL or PostgreSQL

This version (3.x) is designed for GitLab 5.3+.

__If you want to use GitLab CI without GitLab or with older versions you need to use [2-2-stable](https://github.com/gitlabhq/gitlab-ci/tree/2-2-stable#gitlab-ci-is-an-open-source-continuous-integration-server)__

### How it works

__GitLab CI__ is a web application with API and connect to db. 
It manage projects/builds and provide a nice user interface. 
It uses GitLab application to authenticate users.

__GitLab CI Runner__ is a pure ruby application which process builds.
It can be deployed separately and work with GitLab CI through API.

In order to run tests you need at least 1 __GitLab CI__ instance and 1 __GitLab CI Runner__.
However, for running several builds at the same time you may want to setup more than one __GitLab CI Runner__.

Possible Cases: 

* 1 __GitLab CI__ and N __GitLab CI Runner__ instances on same machine
* 1 __GitLab CI__ and N __GitLab CI Runner__ instances on different machines
* 1 __GitLab CI__ and N __GitLab CI Runner__ instances on local machines

![screen](https://raw.github.com/gitlabhq/gitlab-ci/master/app/assets/images/arch.jpg)

The runner runs the line below and then runs the commands in your projects settings

    cd /gitlab-ci-runner/tmp/builds && git clone git@gitlab_server_fqdn:group/project.git project-1 && cd project-1 && git checkout master

For more information see:
[Announcing GitLab CI 3.0](http://blog.gitlab.org/announcing-gitlab-ci-3.0/)
and
[Integrating GitLab CI With GitLab to Enable Distributed Builds](http://blog.gitlab.org/integrating-gitlab-ci-with-gitlab/)

### Installation

* [Installation and setup guide](https://github.com/gitlabhq/gitlab-ci/blob/master/doc/installation.md)

### Getting help

* [Feedback and suggestions forum](http://feedback.gitlab.com/forums/176466-general/category/64310-gitlab-ci) is the place to propose and discuss new features for GitLab CI.
