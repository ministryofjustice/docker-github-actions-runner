#!/usr/bin/dumb-init /bin/bash

export PATH=$PATH:/actions-runner

deregister_runner() {
  echo "Caught SIGTERM. Deregistering runner"
  _TOKEN=$(bash /token.sh)
  RUNNER_TOKEN=$(echo "${_TOKEN}" | jq -r .token)
  ./config.sh remove --token "${RUNNER_TOKEN}"
  exit
}

if [ -z "${GITHUB_URL}" ]; then
  echo "Working with public GitHub" 1>&2
  GITHUB_URL="https://github.com/"
else
  length=${#GITHUB_URL}
  last_char=${GITHUB_URL:length-1:1}

  [[ $last_char != "/" ]] && GITHUB_URL="$GITHUB_URL/"; :
  echo "Github endpoint URL ${GITHUB_URL}"
fi

if [ -z "${RUNNER_NAME}" ]; then
  echo "RUNNER_NAME must be set" 1>&2
  exit 1
fi

if [ -z "${RUNNER_ORG}" ]; then
  echo "RUNNER_ORG must be set" 1>&2
  exit 1
fi

if [ -n "${RUNNER_WORKDIR}" ]; then
  WORKDIR_ARG="--work ${RUNNER_WORKDIR}"
fi

if [ -n "${RUNNER_LABELS}" ]; then
  LABEL_ARG="--labels ${RUNNER_LABELS}"
fi

if [ -z "${RUNNER_TOKEN}" ]; then
  echo "RUNNER_TOKEN must be set" 1>&2
  exit 1
fi

if [ -z "${RUNNER_REPO}" ] && [ -n "${RUNNER_ORG}" ] && [ -n "${RUNNER_GROUP}" ];then
  RUNNER_GROUP_ARG="--runnergroup ${RUNNER_GROUP}"
fi

cd /runner || exit 1

echo "Configuring"
./config.sh \
    --url "${GITHUB_URL}${RUNNER_ORG}" \
    --token "${RUNNER_TOKEN}" \
    --name "${RUNNER_NAME}" \
    "${WORKDIR_ARG}" \
    "${LABEL_ARG}" \
    "${RUNNER_GROUP_ARG}" \
    --unattended \
    --replace

unset RUNNER_TOKEN
trap deregister_runner SIGINT SIGQUIT SIGTERM
exec ./bin/runsvc.sh --once
