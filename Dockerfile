FROM ubuntu:20.04
LABEL maintainer="myoung34@my.apsu.edu"

ARG TARGETPLATFORM
ARG RUNNER_VERSION=2.274.2
ARG DOCKER_VERSION=19.03.12
ENV DEBIAN_FRONTEND=noninteractive
ENV DOCKER_COMPOSE_VERSION="1.27.4"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# hadolint ignore=DL3003,DL4001

COPY install_packages.sh /tmp
RUN /tmp/install_packages.sh

RUN export ARCH=$(echo ${TARGETPLATFORM} | cut -d / -f2) \
  && curl -L -o /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_${ARCH} \
  && chmod +x /usr/local/bin/dumb-init

# Docker download supports arm64 as aarch64 & amd64 as x86_64
RUN export ARCH=$(echo ${TARGETPLATFORM} | cut -d / -f2) \
  && if [ "$ARCH" = "arm64" ]; then export ARCH=aarch64 ; fi \
  && if [ "$ARCH" = "amd64" ]; then export ARCH=x86_64 ; fi \
  && curl -L -o docker.tgz https://download.docker.com/linux/static/stable/${ARCH}/docker-${DOCKER_VERSION}.tgz \
  && tar zxvf docker.tgz \
  && install -o root -g root -m 755 docker/docker /usr/local/bin/docker \
  && rm -rf docker docker.tgz \
  && adduser --disabled-password --gecos "" --uid 1000 runner \
  && groupadd docker \
  && usermod -aG sudo runner \
  && usermod -aG docker runner \
  && echo "%sudo   ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers

# Runner download supports amd64 as x64.
RUN export ARCH=$(echo ${TARGETPLATFORM} | cut -d / -f2) \
  && if [ "$ARCH" = "amd64" ]; then export ARCH=x64 ; fi \
  && mkdir -p /runner \
  && cd /runner \
  && curl -L -o runner.tar.gz https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-${ARCH}-${RUNNER_VERSION}.tar.gz \
  && tar xzf ./runner.tar.gz \
  && rm runner.tar.gz \
  && ./bin/installdependencies.sh \
  && rm -rf /var/lib/apt/lists/*

RUN curl -sL "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
  && chmod +x /usr/local/bin/docker-compose

COPY entrypoint.sh /runner
USER runner
ENTRYPOINT ["/usr/local/bin/dumb-init", "--"]
CMD ["/runner/entrypoint.sh"]
