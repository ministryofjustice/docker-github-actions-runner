# hadolint ignore=DL3007
FROM myoung34/github-runner-base:latest
LABEL maintainer="myoung34@my.apsu.edu"

ENV AGENT_TOOLSDIRECTORY=/opt/hostedtoolcache
RUN mkdir -p /opt/hostedtoolcache

ARG GH_RUNNER_VERSION="2.274.2"
ARG TARGETPLATFORM

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

WORKDIR /actions-runner
COPY install_actions.sh /actions-runner

RUN chmod +x /actions-runner/install_actions.sh \
  && /actions-runner/install_actions.sh ${GH_RUNNER_VERSION} ${TARGETPLATFORM} \
  && rm /actions-runner/install_actions.sh

COPY token.sh /
RUN chmod +x /token.sh

COPY installers/ /installers/.
RUN echo "Installing Tools" \
  && chmod +x /installers/docker-compose.sh \
  && /installers/docker-compose.sh \
  && chmod +x /installers/kubernetes-tools.sh \
  && /installers/kubernetes-tools.sh \
  && chmod +x /installers/nodejs.sh \
  && /installers/nodejs.sh \
  && chmod +x /installers/terraform.sh \
  && /installers/terraform.sh

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
USER runner
ENTRYPOINT ["/entrypoint.sh"]
