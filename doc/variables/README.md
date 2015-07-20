## Variables
When receiving a build from GitLab CI, the runner prepares the build environment.
It starts by setting a list of **predefined variables** (Environment Variables) and a list of **user-defined variables** (Secure Variables)

### Predefined variables (Environment Variables)
| Variable | Description |
|--|--|
| **CI** | Mark that build is executed in CI environment |
| **GITLAB_CI** | Mark that build is executed in GitLab CI environment |
| **CI_SERVER** | Mark that build is executed in CI environment |
| **CI_SERVER_NAME** | CI server that is used to coordinate builds |
| **CI_SERVER_VERSION** | Not yet defined |
| **CI_SERVER_REVISION** | Not yet defined |
| **CI_BUILD_REF** | The commit revision for which project is built |
| **CI_BUILD_BEFORE_SHA** | The first commit that were included in push request |
| **CI_BUILD_REF_NAME** | The branch or tag name for which project is built |
| **CI_BUILD_ID** | The unique id of the current build that GitLab CI uses internally |
| **CI_BUILD_REPO** | The URL to clone the Git repository |
| **CI_PROJECT_ID** | The unique id of the current project that GitLab CI uses internally |
| **CI_PROJECT_DIR** | The full path where the repository is cloned and where the build is ran |

Example values:

```bash
export CI_BUILD_BEFORE_SHA="9df57456fa9de2a6d335ca5edf9750ed812b9df0"
export CI_BUILD_ID="50"
export CI_BUILD_REF="1ecfd275763eff1d6b4844ea3168962458c9f27a"
export CI_BUILD_REF_NAME="master"
export CI_BUILD_REPO="https://gitlab.com/gitlab-org/gitlab-ce.git"
export CI_PROJECT_DIR="/builds/gitlab-org/gitlab-ce"
export CI_PROJECT_ID="34"
export CI_SERVER="yes"
export CI_SERVER_NAME="GitLab CI"
export CI_SERVER_REVISION=""
export CI_SERVER_VERSION=""
```

### User-defined variables (Secure Variables)
**This feature requires `gitlab-runner` with version equal or greater than 0.4.0.**

GitLab CI allows you to define per-project **Secure Variables** that are set in build environment. 
The secure variables are stored out of the repository (the `.gitlab-ci.yml`).
These variables are securely stored in GitLab CI database and are hidden in the build log.
It's desired method to use them for storing passwords, secret keys or whatever you want.

Secure Variables can added by going to `Project > Variables > Add Variable`.

They will be available for all subsequent builds.

### Use variables
The variables are set as environment variables in build environment and are accessible with normal methods that are used to access such variables.
In most cases the **bash** is used to execute build script.
To access variables (predefined and user-defined) in bash environment, prefix the variable name with `$`:
```
job_name:
  script:
    - echo $CI_BUILD_ID
```

You can also list all environment variables with `export` command,
but be aware that this will also expose value of all **Secure Variables** in build log:
```
job_name:
  script:
    - export
```
