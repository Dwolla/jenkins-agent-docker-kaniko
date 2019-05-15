# Jenkins Agent with kaniko

[![](https://images.microbadger.com/badges/image/dwolla/jenkins-agent-kaniko.svg)](https://microbadger.com/images/dwolla/jenkins-agent-kaniko)
[![license](https://img.shields.io/github/license/dwolla/jenkins-agent-docker-kaniko.svg?style=flat-square)](https://github.com/Dwolla/jenkins-agent-docker-kaniko/blob/master/LICENSE.md)

## Overview

`jenkins-agent-docker-kaniko` is a Docker image based on [Dwolla’s core
Jenkins Agent Docker image](https://github.com/Dwolla/jenkins-agent-docker-core).

It enables Docker images to be built and pushed using
[kaniko](https://github.com/GoogleContainerTools/kaniko) and provides
utilities for deploying artifacts.

## Available Utilities

* [`kaniko`](https://github.com/GoogleContainerTools/kaniko)

kaniko is a tool to build container images from a Dockerfile inside a
container or Kubernetes cluster.

* Berkshelf

[Berkshelf](https://docs.chef.io/berkshelf.html) is a dependency manager for
Chef cookbooks.

The `hooks` directory is provided to customize parts of the automated Docker
Hub build process. To build the image locally, run `./hooks/build`.

## Notes

### `UsePerfData`

When invoking `agent.jar` specify `/kaniko` for the `-workDir` option. This
ensures artifacts included by Jenkins will be whitelisted by `kaniko`. Also,
if specifying custom options for `JAVA_OPTS`, avoid the use of
`-XX:+UsePerfData`. Otherwise, a `/tmp/hsperfdata_root` directory will be
included in the resulting image.

### Invoking `agent.jar`

`jenkins-agent-docker-core:alpine` creates an `ENTRYPOINT` for the Jenkins
Remoting JAR (`agent.jar`). The Jenkins Remoting JAR can be invoked using the
following command:

```bash
docker run dwolla/jenkins-agent-kaniko:latest
  -url https://ci.dwolla.net/ <SLAVE_NODE_SECRET> <SLAVE_NODE_NAME>
```
