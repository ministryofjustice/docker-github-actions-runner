# hadolint ignore=DL3007
FROM myoung34/github-runner-base:latest
LABEL maintainer="myoung34@my.apsu.edu"

ARG GH_RUNNER_VERSION="2.274.2"
ARG TARGETPLATFORM

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN adduser --disabled-password --gecos "" --uid 1000 runner \
  && usermod -aG sudo runner \
  && usermod -aG docker runner \
  && echo "%sudo   ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers

WORKDIR /actions-runner
COPY install_actions.sh /actions-runner

RUN chmod +x /actions-runner/install_actions.sh \
  && /actions-runner/install_actions.sh ${GH_RUNNER_VERSION} ${TARGETPLATFORM} \
  && rm /actions-runner/install_actions.sh

COPY token.sh /
RUN chmod +x /token.sh


RUN echo AGENT_TOOLSDIRECTORY=/opt/hostedtoolcache > /runner.env \
  && mkdir /opt/hostedtoolcache \
  && chgrp runner /opt/hostedtoolcache \
  && chmod g+rwx /opt/hostedtoolcache

COPY installers/ /installers/.
RUN echo "Installing Tools"
RUN chmod +x /installers/kubernetes-tools.sh && /installers/kubernetes-tools.sh
RUN chmod +x /installers/nodejs.sh && /installers/nodejs.sh
RUN chmod +x /installers/terraform.sh && /installers/terraform.sh

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
USER runner
ENTRYPOINT ["/entrypoint.sh"]
