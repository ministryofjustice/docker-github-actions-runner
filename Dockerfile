# hadolint ignore=DL3007
FROM ubuntu:20.04
LABEL maintainer="analytics-platform-tech@digital.justice.gov.uk"

ARG GH_RUNNER_VERSION="2.274.2"
ARG TARGETPLATFORM
ARG GIT_VERSION="2.29.0"
ARG DUMB_INIT_VERSION="1.2.2"
ARG DOCKER_KEY="7EA0A9C3F273FCD8"
ENV DOCKER_COMPOSE_VERSION="1.27.4" \
  DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt update -y \
  && apt install -y software-properties-common \
  && add-apt-repository -y ppa:git-core/ppa \
  && apt update -y \
  && apt install -y --no-install-recommends \
  apt-transport-https \
  awscli \
  build-essential \
  curl \
  ca-certificates \
  dirmngr \
  dnsutils \
  dumb-init \
  ftp \
  gettext \
  git \
  gnupg-agent \
  iproute2 \
  iputils-ping \
  jq \
  libcurl4-openssl-dev \
  liblttng-ust0 \
  libunwind8 \
  locales \
  netcat \
  openssh-client \
  parallel \
  rsync \
  shellcheck \
  sudo \
  tar \
  telnet \
  time \
  tzdata \
  unzip \
  upx \
  wget \
  zlib1g-dev \
  zip \
  zstd \
  && rm -rf /var/lib/apt/lists/* \
  c_rehash

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ${DOCKER_KEY} \
  && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
  && add-apt-repository "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
  && apt-get update \
  && apt-get install -y docker-ce docker-ce-cli containerd.io --no-install-recommends --allow-unauthenticated \
  && rm -rf /var/lib/apt/lists/*

RUN curl -sL "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
  && chmod +x /usr/local/bin/docker-compose

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
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh \
  && chmod +x /installers/*

RUN /installers/packages.sh
RUN /installers/kubernetes-tools.sh
RUN /installers/nodejs.sh
RUN /installers/terraform.sh

USER runner
ENTRYPOINT ["/entrypoint.sh"]
