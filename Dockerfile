FROM gcr.io/kaniko-project/executor:v0.9.0 as kaniko

FROM dwolla/jenkins-agent-core:alpine

ARG VCS_REF
ARG VCS_URL
ARG BUILD_DATE
ARG VERSION

LABEL maintainer="Dwolla Dev <dev+jenkins-agent-kaniko@dwolla.com>" \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-url="https://github.com/Dwolla/jenkins-agent-docker-kaniko" \
    org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.version=$VERSION

# We disable the JVM perfdata feature by adding `-XX:-UsePerfData` to the
# `JAVA_OPTS` environment variable. Otherwise an additional
# `/tmp/hsperfdata_root` directory will show up in images we create.
ENV JAVA_OPTS -XX:-UsePerfData

COPY --from=kaniko /kaniko /kaniko

# kaniko requires we run as root.
USER root

# The /kaniko directory is whitelisted when building images, so it's where we
# perform all our desired work.
WORKDIR /kaniko
