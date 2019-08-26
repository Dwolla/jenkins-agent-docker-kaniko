FROM gcr.io/kaniko-project/executor:v0.11.0 as kaniko

FROM busybox:1.31-glibc as busybox

FROM dwolla/jenkins-agent-core:debian

ARG VCS_REF
ARG VCS_URL
ARG BUILD_DATE
ARG VERSION

LABEL maintainer="Dwolla Dev <dev+jenkins-agent-kaniko@dwolla.com>" \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-url=$VCS_URL \
    org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.version=$VERSION

# apk and kaniko must be run as root.
USER root

# Install base packages
RUN apt-get update && \
    apt-get remove -y python && \
    apt autoremove -y && \
    apt-get install -y --no-install-recommends \
                ca-certificates \
                ca-certificates-java \
                libnss3 \
      && \
    apt-get clean

# We disable the JVM PerfDataFile feature by adding `-XX:-UsePerfData` to the
# `JAVA_OPTS` environment variable. Otherwise, an additional
# `/tmp/hsperfdata_root` directory will show up in images we create.
ENV JAVA_OPTS -XX:-UsePerfData

COPY --from=kaniko /kaniko /kaniko
COPY --from=busybox /bin /busybox

ENV PATH=/busybox:$PATH

# Docker volumes include an entry in /proc/self/mountinfo. This file is used
# when kaniko builds the list of whitelisted directories. Whitelisted
# directories are persisted between stages and are not included in the final
# Docker image.
VOLUME /busybox

# The /kaniko directory is whitelisted by default. Its contents is not deleted
# between stages, nor is it included in the final Docker image.
WORKDIR /kaniko
