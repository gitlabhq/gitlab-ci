# API


## Register Runner

Before we start we need to get a token from the server. Go to your gitlab ci
instance and get it from the runners page. 

Then we send in with a public key and if it's valid we'll get 
a validated token back.

```POST /runners/register.json```

Send this:

```
{
    public_key: "<your public key>", # one that you've registered with gitlab
    token: "<token from gitlab-ci>"
}
```

You get this back if successful:

```
{
    id: "<runner id>",
    token: "<use this token>"
}
```

## Register a new build

```POST /builds/register.json```

You need to send your token:

```
{
    token: "<your token>"
}
```

You will get back your new build info:

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

## Update build

```PUT /builds/:id.json```

Send updated info

```
{
    token: "<your token>",
    state: "<valid state>", # "success" | "fail"
    trace: "extra tracing info..."
}
```