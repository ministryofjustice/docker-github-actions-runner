#!/bin/bash -x

apt install -y software-properties-common
add-apt-repository -y ppa:git-core/ppa
apt update -y
apt install -y --no-install-recommends \
  apt-transport-https \
  awscli \
  build-essential \
  curl \
  ca-certificates \
  dirmngr \
  dnsutils \
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
  software-properties-common \
  sudo \
  tar \
  telnet \
  time \
  tzdata \
  unzip \
  upx \
  wget \
  zip \
  zlib1g-dev \
  zstd

rm -rf /var/lib/apt/lists/*
c_rehash
