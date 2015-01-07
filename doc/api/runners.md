# Runners API

## Runners

### Retrieve all runners

__Authentication is done by GitLab user token & GitLab url__

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


__Authentication is done by GitLab CI runners registration token or CI project token__

Used to make Gitlab CI aware of available runners.

    POST /runners/register

Parameters:

  * `token` (required) - The registration token. It is 2 types of token you can pass here. 

1. Global registration token (admins only) at /admin/runners
2. Project token for project-specific runners

Returns:

```json
{
  "id" : 85,
  "token" : "12b68e90394084703135"
}
```
