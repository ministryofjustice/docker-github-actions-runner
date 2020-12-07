#!/usr/bin/env bash

add-apt-repository -y ppa:git-core/ppa

apt-get update -y

apt-get install -y software-properties-common

apt-get install -y --no-install-recommends \
  build-essential \
  curl \
  ca-certificates \
  dnsutils \
  ftp \
  git \
  iproute2 \
  iputils-ping \
  jq \
  libunwind8 \
  locales \
  netcat \
  openssh-client \
  parallel \
  rsync \
  shellcheck \
  sudo \
  telnet \
  time \
  tzdata \
  unzip \
  upx \
  wget \
  zip \
  zstd

rm -rf /var/lib/apt/lists/*
