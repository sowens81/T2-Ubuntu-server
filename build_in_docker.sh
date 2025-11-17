#!/bin/bash

set -eu -o pipefail

DOCKER_IMAGE_NAME=t2-iso-builder
DOCKER_IMAGE_TAG=latest
DOCKER_IMAGE=${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} 

docker build -t ${DOCKER_IMAGE} -f Dockerfile .

# docker pull ${DOCKER_IMAGE}
docker run \
  --privileged \
  --rm \
  -it \
  -v "$(pwd)":/repo \
  -v /sys/fs/cgroup:/sys/fs/cgroup:rw \
  -v /lib/modules:/lib/modules \
  -v /dev:/dev \
  ${DOCKER_IMAGE} \
  /bin/bash -c 'cd /repo && ./build.sh'
