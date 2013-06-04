# GitLab CI is an open-source continuous integration server

* [![build status](https://secure.travis-ci.org/gitlabhq/gitlab-ci.png)](https://travis-ci.org/gitlabhq/gitlab-ci)
* [![Code Climate](https://codeclimate.com/github/gitlabhq/gitlab-ci.png)](https://codeclimate.com/github/gitlabhq/gitlab-ci)
* [![Dependency Status](https://gemnasium.com/gitlabhq/gitlab-ci.png)](https://gemnasium.com/gitlabhq/gitlab-ci)
* [![Coverage Status](https://coveralls.io/repos/gitlabhq/gitlab-ci/badge.png?branch=master)](https://coveralls.io/r/gitlabhq/gitlab-ci)

![Screen](https://github.com/downloads/gitlabhq/gitlab-ci/gitlab_ci_preview.png)

### Requirements

**The project is designed for the Linux operating system.**

We officially support (recent versions of) these Linux distributions:

- Ubuntu Linux
- Debian/GNU Linux

__We recommend to use server with at least 756MB RAM for gitlab-ci instance.__


__master branch contains unstable 3.0. Use 2-2-stable branch__


### How it works

__GitLab CI__ is a web application with API and connect to db. 
It manage projects/builds and provide a nice user interface. 
It uses GitLab application to authenticate users.

__GitLab CI Runner__ is a pure ruby application which process builds.
It can be deployed separately and work with GitLab CI through API.

In order to run tests you need at least 1 __GitLab CI__ instance and 1 __GitLab CI Runner__.
Hovewer for running several builds at same time you may want to setup more then one __GitLab CI Runner__.

Possible Cases: 

* 1 __GitLab CI__ and N __GitLab CI Runner__ instances on same machine
* 1 __GitLab CI__ and N __GitLab CI Runner__ instances on different machines
* 1 __GitLab CI__ and N __GitLab CI Runner__ instances on local machines


### Installation

* [Installation and setup guide for v2.2](https://github.com/gitlabhq/gitlab-ci/blob/2-2-stable/doc/installation.md)

### Getting help

* [Feedback and suggestions forum](http://feedback.gitlab.com/forums/176466-general/category/64310-gitlab-ci) is the place to propose and discuss new features for GitLab CI.
