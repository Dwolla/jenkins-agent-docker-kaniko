FROM gcr.io/kaniko-project/executor:v0.9.0 as kaniko

FROM dwolla/jenkins-agent-core:alpine

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
RUN apk add --no-cache --update \
      build-base \
      make

# Install Ruby
# This command was taken from cybercode/alpine-ruby:
# https://github.com/cybercode/alpine-ruby
RUN apk add --no-cache --update \
      ca-certificates \
      libstdc++ \
      ruby \
      ruby-bigdecimal \
      ruby-bundler \
      ruby-dev \
      ruby-io-console \
      ruby-irb \
      ruby-json \
      ruby-rake \
      tzdata \
      && echo 'gem: --no-document' > /etc/gemrc

# Address 'java.io.FileNotFoundException: /usr/lib/libnss3.so' issue
# https://bugs.alpinelinux.org/issues/10126
RUN apk add --no-cache nss

# Install Berkshelf
RUN gem install --no-rdoc --no-ri berkshelf

# We disable the JVM PerfDataFile feature by adding `-XX:-UsePerfData` to the
# `JAVA_OPTS` environment variable. Otherwise, an additional
# `/tmp/hsperfdata_root` directory will show up in images we create.
ENV JAVA_OPTS -XX:-UsePerfData

COPY --from=kaniko /kaniko /kaniko

# The /kaniko directory is whitelisted when building images, so it's where we
# perform all our desired work.
WORKDIR /kaniko
