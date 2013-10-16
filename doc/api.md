# API


## Register Runner

Before we start we need to get a registration token from the server. Go to your gitlab ci
instance and get it from the runners page. 

Then we send in with a public key and if it's valid we'll get 
a validated token back.

```POST /runners/register.json```

Send this:

```
{
    public_key: "<the runner's ssh public key>", # GitLab CI will actually add this key to GitLab for you.
    token: "<token from gitlab-ci>"
}
```

You get this back if successful:

```
{
    id: "<runner id>",
    token: "<runner token>"
}
```

## Request a new build

```POST /builds/register.json```

You need to send your token:

```
{
    token: "<your token>"
}
```

If there ia a pending build available, you will get back information about it:

```
{
      id: 'build_id',
      project_id: 'project_id',
      commands: 'commands to execute',
      repo_url: 'repo_url',
      ref: 'git commit sha',
      ref_name: 'git ref name',
}
```

Otherwise you will get

```
{
    'message': '404 Not Found'
}
```


## Update build

```PUT /builds/:id.json```

Send updated info

```
{
    token: "<your token>",
    state: "<valid state>", # waiting, running, failed and success 
    trace: "log or output of build (UTF-8 encoded)..."
}
```
