FROM summerwind/actions-runner:v2.274.1

ENV DOCKER_COMPOSE_VERSION="1.27.4"

USER root
RUN curl -sL "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
  && chmod +x /usr/local/bin/docker-compose
USER runner
