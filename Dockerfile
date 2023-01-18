ARG BASE_IMAGE_VERSION="v2.299.1-ubuntu-20.04"
FROM ghcr.io/actions/actions-runner-controller/actions-runner:${BASE_IMAGE_VERSION}

ARG KUBECTL_VERSION="v1.26.0"
ARG HELM_VERSION="v3.10.3"
ARG KUSTOMIZE_VERSION="v4.5.7"
ARG NODE_VERSION="lts"
ARG NPM_VERSION="9.3.1"
ARG YARN_VERSION="1.22.19"
ARG TERRAFORM_VERSION="1.3.7"

USER root

# kubectl
RUN curl --location https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl --output kubectl \
    && install --owner root --group root --mode 0755 kubectl /usr/local/bin/kubectl \
    && rm --force --recursive kubectl

# helm
RUN curl --location https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz --output helm-${HELM_VERSION}-linux-amd64.tar.gz \
    && tar -xvf helm-${HELM_VERSION}-linux-amd64.tar.gz \
    && install --owner root --group root --mode 0755 linux-amd64/helm /usr/local/bin/helm \
    && rm --force --recursive helm-${HELM_VERSION}-linux-amd64.tar.gz linux-amd64

# kustomize
RUN curl --location https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_amd64.tar.gz --output kustomize_${KUSTOMIZE_VERSION}_linux_amd64.tar.gz \
    && tar -xvf kustomize_${KUSTOMIZE_VERSION}_linux_amd64.tar.gz \
    && install --owner root --group root --mode 0755 kustomize /usr/local/bin/kustomize \
    && rm --force --recursive kustomize_${KUSTOMIZE_VERSION}_linux_amd64.tar.gz kustomize

# Node and Friends
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - \
    && apt-get install --yes nodejs \
    && npm install --global npm@${NPM_VERSION} \
    && npm install --global yarn@${YARN_VERSION} \
    && npm install --global \
         grunt \
         gulp \
         parcel-bundler \
         typescript \
         newman \
         webpack \
         webpack-cli

# Terraform
RUN curl --location https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip --output terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && install --owner root --group root --mode 0755 terraform /usr/local/bin/terraform \
    && rm --force --recursive terraform_${TERRAFORM_VERSION}_linux_amd64.zip terraform

RUN rm --force --recursive /var/lib/apt/lists/*

USER runner
