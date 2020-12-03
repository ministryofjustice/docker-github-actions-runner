FROM summerwind/actions-runner:v2.274.2

ENV DOCKER_COMPOSE_VERSION="1.27.4"

USER root
RUN curl -sL "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
  && chmod +x /usr/local/bin/docker-compose

RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  awscli \
  apt-transport-https \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /tmp/*

ENV node_major_verison="14"

RUN echo "Installing Node ${node_major_verison}" \
  && apt-get update \
  && curl -sL https://deb.nodesource.com/setup_${node_major_verison}.x -o nodesource_setup.sh \
  && bash nodesource_setup.sh \
  && apt-get install nodejs -y

USER runner
