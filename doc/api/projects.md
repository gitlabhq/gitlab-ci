# Projects API

This API is intended to aid in the setup and configuration of
projects on Gitlab CI. 

__Authentication is done by GitLab user token & GitLab url__

## Projects

### List Authorized Projects

Lists all projects that the authenticated user has access to.

```
GET /projects
```

Returns:

```json
    [
  {
    "id" : 271,
    "name" : "gitlabhq",
    "timeout" : 1800,
    "token" : "iPWx6WM4lhHNedGfBpPJNP",
    "default_ref" : "master",
    "gitlab_url" : "http://demo.gitlabhq.com/gitlab/gitlab-shell",
    "always_build" : false,
    "polling_interval" : null,
    "public" : false,
    "ssh_url_to_repo" : "git@demo.gitlab.com:gitlab/gitlab-shell.git",
    "gitlab_id" : 3
  },
  {
    "id" : 272,
    "name" : "gitlab-ci",
    "timeout" : 1800,
    "token" : "iPWx6WM4lhHNedGfBpPJNP",
    "default_ref" : "master",
    "gitlab_url" : "http://demo.gitlabhq.com/gitlab/gitlab-shell",
    "always_build" : false,
    "polling_interval" : null,
    "public" : false,
    "ssh_url_to_repo" : "git@demo.gitlab.com:gitlab/gitlab-shell.git",
    "gitlab_id" : 4
  }
]
```

### List Owned Projects

Lists all projects that the authenticated user owns.

```
GET /projects/owned
```

Returns:

```json
[
  {
    "id" : 272,
    "name" : "gitlab-ci",
    "timeout" : 1800,
    "token" : "iPWx6WM4lhHNedGfBpPJNP",
    "default_ref" : "master",
    "gitlab_url" : "http://demo.gitlabhq.com/gitlab/gitlab-shell",
    "always_build" : false,
    "polling_interval" : null,
    "public" : false,
    "ssh_url_to_repo" : "git@demo.gitlab.com:gitlab/gitlab-shell.git",
    "gitlab_id" : 4
  }
]
```

### Single Project

Returns information about a single project for which the user is
authorized.

    GET /projects/:id

Parameters:

  * `id` (required) - The ID of the Gitlab CI project

### Create Project

Creates a Gitlab CI project using Gitlab project details.

    POST /projects/:id

Parameters:

  * `name` (required) - The name of the project
  * `gitlab_id` (required) - The ID of the project on the Gitlab instance
  * `gitlab_url` (required) - The web url of the project on the Gitlab instance
  * `ssh_url_to_repo` (required) - The gitlab SSH url to the repo
  * `default_ref` (optional) - The branch to run on (default to `master`)

### Update Project

Updates a Gitlab CI project using Gitlab project details that the
authenticated user has access to.

    PUT /projects/:id

Parameters:

  * `name` - The name of the project
  * `gitlab_id` - The ID of the project on the Gitlab instance
  * `gitlab_url` - The web url of the project on the Gitlab instance
  * `ssh_url_to_repo` - The gitlab SSH url to the repo
  * `default_ref` - The branch to run on (default to `master`)

### Remove Project

Removes a Gitlab CI project that the authenticated user has access to.

    DELETE /projects/:id

Parameters:

  * `id` (required) - The ID of the Gitlab CI project

### Link Project to Runner

Links a runner to a project so that it can make builds (only via
authorized user).

    POST /projects/:id/runners/:runner_id

Parameters:

  * `id` (required) - The ID of the Gitlab CI project
  * `runner_id` (required) - The ID of the Gitlab CI runner

### Remove Project from Runner

Removes a runner from a project so that it can not make builds (only
via authorized user).

    DELETE /projects/:id/runners/:runner_id

Parameters:

  * `id` (required) - The ID of the Gitlab CI project
  * `runner_id` (required) - The ID of the Gitlab CI runner

### List All Jobs for a Project

List the jobs associated to a Gitlab CI Project (only via
authorized user).

    GET /projects/:id/jobs

Parameters:

  * `id` (required) - The ID of the Gitlab CI project

### Add a Job to a Project

Adds a Job to a Gitlab CI Project (only via
authorized user).

    POST /projects/:id/jobs

Parameters:

  * `id` (required) - The ID of the Gitlab CI project
  * `name` (required) - The name of the Job to add
  * `commands` (required) - The script commands of the job

### Remove a Job from a Project

Removes a Job from a Gitlab CI Project (only
via authorized user).

    DELETE /projects/:id/jobs/:job_id

Parameters:

  * `id` (required) - The ID of the Gitlab CI project
  * `job_id` (required) - The ID of the Job

