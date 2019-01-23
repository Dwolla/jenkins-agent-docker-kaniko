# Jenkins Agent with kaniko

[![](https://images.microbadger.com/badges/image/dwolla/jenkins-agent-kaniko.svg)](https://microbadger.com/images/dwolla/jenkins-agent-kaniko)
[![license](https://img.shields.io/github/license/dwolla/jenkins-agent-docker-kaniko.svg?style=flat-square)](https://github.com/Dwolla/jenkins-agent-docker-kaniko/blob/master/LICENSE)

Docker image based on [Dwolla’s core Jenkins Agent Docker image](https://github.com/Dwolla/jenkins-agent-docker-core) making [`kaniko`](https://github.com/GoogleContainerTools/kaniko) available to Jenkins jobs.

The `hooks` directory is provided to customize parts of the automated Docker Hub build process. To build the image locally, run `/hooks/build`.
