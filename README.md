# Jenkins Agent Docker Kaniko

![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/dwolla/jenkins-agent-docker-kaniko?color=blue)
[![](https://images.microbadger.com/badges/image/dwolla/jenkins-agent-docker-kaniko.svg)](https://microbadger.com/images/dwolla/jenkins-agent-kaniko)
[![](https://images.microbadger.com/badges/version/dwolla/jenkins-agent-docker-kaniko.svg)](https://microbadger.com/images/dwolla/jenkins-agent-kaniko)
![GitHub](https://img.shields.io/github/license/NickolasHKraus/jenkins-agent-docker-kaniko?color=blue)

[Docker Hub](https://cloud.docker.com/u/dwolla/repository/docker/dwolla/jenkins-agent-kaniko)

Jenkins Agent Docker Kaniko contains the [Jenkins Remoting](https://jenkins.io/projects/remoting/) library and [Kaniko](https://github.com/GoogleContainerTools/kaniko). It can be used with [Amazon EC2 Container Service Plugin](https://wiki.jenkins.io/display/JENKINS/Amazon+EC2+Container+Service+Plugin) to build Docker images from a container running on an Amazon ECS cluster.

## What's in the image?

Jenkins Agent Docker Kaniko contains the following images:

### `jenkins/jnlp-slave`

`jenkins/jnlp-slave` contains [Jenkins Remoting](https://github.com/jenkinsci/remoting), a library which implements the communication layer in Jenkins.

[Docker Hub](https://hub.docker.com/r/jenkins/jnlp-slave/) | [GitHub](https://github.com/jenkinsci/docker-jnlp-slave)

### `gcr.io/kaniko-project/executor`

`gcr.io/kaniko-project/executor` contains [Kaniko](https://github.com/GoogleContainerTools/kaniko), a tool that can build container images from a `Dockerfile` inside a container or Kubernetes cluster without a Docker daemon.

[GitHub](https://github.com/GoogleContainerTools/kaniko)

### `busybox`

`busybox` ([busybox.net](https://busybox.net/)) combines tiny versions of many common UNIX utilities into a single small executable.

[Docker Hub](https://hub.docker.com/_/busybox)

## Usage

Jenkins Agent Docker Kaniko can be run via Docker using the following command:

```bash
$ docker run \
  -it \
  --rm \
  -v ~/path/to/repository:/repository: \
  -v ~/.docker/config.json:/kaniko/.docker/config.json: \
  -w /repository \
  dwolla/jenkins-agent-kaniko:latest \
  /bin/sh
```

The Kaniko executor can be invoked using the following:

```bash
IMAGE_ID=registry/repository && \
IMAGE_TAG=$(git rev-parse HEAD) && \
export DOCKER_CONFIG=/kaniko/.docker && \
/kaniko/executor \
  --context $(pwd) \
  --dockerfile $(pwd)/Dockerfile \
  --destination $IMAGE_ID:$IMAGE_TAG \
  --destination $IMAGE_ID:latest \
  --force
```

### Credentials

Kaniko uses the Docker configuration file (typically `$HOME/.docker/config.json`) for configuration and authentication.

In order to provide Kaniko with this file, `config.json` can be mounted from the host:

```bash
docker run \
  ...
  -v ~/.docker/config.json:/kaniko/.docker/config.json: \
```

The path to `config.json` can then be set using the `DOCKER_CONFIG` environment variable:

```bash
export DOCKER_CONFIG=/kaniko/.docker
```

It should be noted that `config.json` is mounted within `/kaniko`, since this directory is whitelisted by Kaniko and therefore its contents are persisted between stages.

### Credentials Management

Kaniko works by fetching and extracting the filesystem of a Docker image (designated by the `FROM` instruction) to root (`/`). It executes each command in order and takes a snapshot of the filesystem after each command. This snapshot is created in user space by walking the filesystem and comparing it to the prior state that was stored in memory. It appends any modifications to the filesystem as a new layer to the base image and makes any relevant changes to image metadata. After executing every command in the `Dockerfile`, the executor pushes the newly built image to the desired registry.

The Kaniko executor image is built from scratch and contains only a static Go binary plus the configuration files needed for pushing and pulling images. As such, it is normally invoked directly and not included in an image as a new build stage. We have found that images built using a Docker image that includes the Kaniko executor as a dependency (`FROM gcr.io/kaniko-project/executor:v0.10.0 as kaniko`) *may* differ from those built using Docker.

For this reason, it is recommended that you include as few utilities or libraries as possible it the Kaniko image.

However, if, for example, you need access to AWS CLI in order to pull `config.json` or secrets from an S3 bucket, you can do so using the following:

```Dockerfile
RUN apk add --update --no-cache \
      curl \
      python3

# install the AWS CLI using the bundled installer
RUN curl 'https://s3.amazonaws.com/aws-cli/awscli-bundle.zip' \
      -o 'awscli-bundle.zip' && \
      unzip awscli-bundle.zip && \
      python3 ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
```
