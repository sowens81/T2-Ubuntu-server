#!/bin/bash

set -eu -o pipefail

DOCKER_IMAGE=t2-iso-builder:latest

docker pull ${DOCKER_IMAGE}
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
