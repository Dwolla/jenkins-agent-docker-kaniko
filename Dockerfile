FROM gcr.io/kaniko-project/executor:v0.7.0 as kaniko

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

COPY --from=kaniko /kaniko /kaniko

USER root
RUN chown -R jenkins /kaniko 

USER jenkins
