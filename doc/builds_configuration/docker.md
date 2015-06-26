## Use Docker to build your projects
GitLab-CI allows to use Docker containers to build projects. `gitlab-runner` when installed on server with `Docker Engine` creates a new build container for each build. It makes it easier to have reproducible build environment, but also to easily replay all build steps on workstation.

### Register Docker runner
To use `gitlab-runner` with `Docker` you need to register `runner` with `docker` executor:

```
gitlab-ci-multi-runner register \
  --url "https://ci.gitlab.com/" \
  --registration-token "PROJECT_REGISTRATION_TOKEN" \
  --description "docker-ruby-2.1" \
  --executor "docker" \
  --docker-image ruby:2.1 \
  --docker-postgres latest \
  --docker-mysql latest
```

The above example will create a new runner that uses `docker` executor. To build projects it will use `ruby:2.1` image and will allow to access `postgres` and `mysql` databases for time of the build.

### What is image?
The image is the name of any repository that is present in local Docker Engine or any repository that can be found at [Docker Hub](https://registry.hub.docker.com/). If you still don't know what it is, please read the [Docker Fundamentals](https://docs.docker.com/introduction/understanding-docker/).

### What is service?
Service is just another image that is run for time of your build and is linked to your build. This allows you to access the service image during build time. The service image can run any application, but most common use case is to run some database container, ie.: `mysql`. It's easier and faster to use existing image, run it as additional container than install `mysql` on your build container every time.

#### How is service linked to the build?
There's good document that describes how `docker` linking works: [Linking containers together](https://docs.docker.com/userguide/dockerlinks/). To summarize: if you add `mysql` as service to your application, this image will be used to create container that is linked to build container. The service container for MySQL will be accessible under hostname `mysql`. So, **to access your database service you have to connect to host: `mysql` instead of socket or `localhost`**.

### How to use other images as services?
You are not limited to have only database services. You can hand modify `config.toml` to add any image as service found at [Docker Hub](https://registry.hub.docker.com/). Look for `[runners.docker]` section:
```
[runners.docker]
  image = "ruby:2.1"
  services = ["mysql:latest", "postgres:latest"]
```

For example you need `wordpress` instance to test some API integration with `Wordpress`. You can for example use this image: [tutum/wordpress](https://registry.hub.docker.com/u/tutum/wordpress/). This is image that have fully preconfigured `wordpress` and have `MySQL` server built-in:
```
[runners.docker]
  image = "ruby:2.1"
  services = ["mysql:latest", "postgres:latest", "tutum/wordpress:latest"]
```

Next time when you run your application the `tutum/wordpress` will be started and you will have access to it from your build container under hostname: `tutum_wordpress`.

Alias hostname for the service is made from the image name:
1. Everything after `:` is stripped,
2. '/' is replaced to `_`.

### Overwrite image and services
It's possible to overwrite `docker-image` and specify services from `.gitlab-ci.yml`. If you add at the top of your `.gitlab-ci.yml` `image` and `services` the `Docker` executor will use the values defined in YAML instead of the ones that were specified during runner's registration.
```
image: ruby:2.2
services:
  - postgres:9.3
before_install:
  - bundle install
  
test:
  script:
  - bundle exec rake spec
```

It's also possible to define image and service for specific job:
```
before_install:
  - bundle install

test:2.1:
  image: ruby:2.1
  services:
  - postgres:9.3
  script:
  - bundle exec rake spec

test:2.2:
  image: ruby:2.2
  services:
  - postgres:9.4
  script:
  - bundle exec rake spec
```

#### How to enable overwritting?
To have that feature working you have to **enable it first** (it's disabled by default for security reasons). You can do that by hand modyfing runner configuration: `config.toml`. Please go to section where is `[runners.docker]` definition for your runner. Add `allowed_images` and `allowed_services` to specify what images are allowed to be picked from `.gitlab-ci.yml`:
```
[runners.docker]
  image = "ruby:2.1"
  allowed_images = ["ruby:*", "python:*"]
  allowed_services = ["mysql:*", "redis:*"]
```
This enables you to use in your `.gitlab-ci.yml` any image that matches above wildcards. You will be able to pick any `ruby` and `python` version, but not any other image. The same apply for services. 

If you are courageous enough, because you run it for your personal or trusted projects, you can make it fully open and accept everything:
```
[runners.docker]
  image = "ruby:2.1"
  allowed_images = ["*"]
  allowed_services = ["*"]
```

**It the feature is not enabled, or image isn't allowed the error message will be put into the build log.**

### How it works?
1. Create any service container: `mysql`, `postgresql`, `mongodb`, `redis`.
1. Create cache container to store all volumes as defined in `config.toml` and `Dockerfile` of build image (`ruby:2.1` as in above example).
1. Create build container and link any service container to build container.
1. Start build container and send build script to the container.
1. Run build script.
1. Checkout code in: `/builds/group-name/project-name/`.
1. Run any step defined in `.gitlab-ci.yml`.
1. Check exit status of build script.
1. Remove build container and all created service containers.

### How to debug build locally?
1. Create build environment locally first using following commands:
```
$ docker run -d -n build-mysql mysql:latest
$ docker run -d -n build-postgres postgres:latest
$ docker run -n build -it -l mysql:build-mysql -l postgres:build-postgres ruby:2.1 /bin/bash
```
This will create two service containers (MySQL and PostgreSQL) that are linked to build container created as a last one.

1. Then in context of docker container you can copy-paste your build script:
```
$ git clone https://gitlab.com/gitlab-org/gitlab-ci-multi-runner.git /builds/gitlab-org/gitlab-ci-multi-runner
$ cd /builds/gitlab-org/gitlab-ci-multi-runner
$ make <- or any other build step
```

1. At the end remove all containers:
```
docker rm -f -v build build-mysql build-postgres
```
This will forcefully (the `-f` switch) remove build container and service containers and all volumes (the `-v` switch) that were created with the container creation.
