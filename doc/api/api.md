# Gitlab CI API

This API is intended to aid in the setup and configuration of
projects, builds and runners on Gitlab CI.  Authentication is done by
sending the `private-token` of a valid user and the `url` of an
authorized Gitlab instance via a query string along with the API
request:

    GET http://ci.example.com/api/v1/projects?private_token=QVy1PB7sTxfy4pqfZM1U&url=http://demo.gitlab.com/

If preferred, you may instead send the `private-token` as a header in
your request:

    curl --header "PRIVATE-TOKEN: QVy1PB7sTxfy4pqfZM1U" "http://ci.example.com/api/v1/projects?url=http://demo.gitlab.com/"

All API requests are serialized using JSON.  You don't need to specify
`.json` at the end of API URL.

# API Requests

This lists all the requests that can be made via the API.

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
    "scripts" : "ls",
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
    "scripts" : "ls",
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
    "scripts" : "ls",
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
  * `scripts` (optional) - The shell script provided for a runner to run (defaults to `ls -al`)
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
  * `scripts` - The shell script provided for a runner to run (defaults to `ls -al`)
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

## Runners

### Retrieve all runners

Used to get information about all runners registered on the Gitlab CI
instance.

    GET /runners

Returns:

```json
[
  {
    "id" : 85,
    "token" : "12b68e90394084703135"
  },
  {
    "id" : 86,
    "token" : "76bf894e969364709864"
  },
]
```

### Register a new runner

Used to make Gitlab CI aware of available runners.

    POST /runners/register

Parameters:

  * `token` (required) - The unique token of runner
  * `public_key` (required) - Deploy key used to get projects

Returns:

```json
{
  "id" : 85,
  "token" : "12b68e90394084703135"
}
```

## Builds

### Runs oldest pending build by runner

    POST /builds/register

Parameters:

  * `token` (required) - The unique token of runner

Returns:

```json
{
  "id" : 79,
  "commands" : "",
  "path" : "",
  "ref" : "",
  "sha" : "",
  "project_id" : 6,
  "repo_url" : "git@demo.gitlab.com:gitlab/gitlab-shell.git",
  "before_sha" : ""
}
```


### Update details of an existing build

    PUT /builds/:id

Parameters:

  * `id` (required) - The ID of a project
  * `state` (optional) - The state of a build
  * `trace` (optional) - The trace of a build
