#!/bin/bash

set -eu -o pipefail

DOCKER_IMAGE=ubuntu:24.04

docker pull ${DOCKER_IMAGE}
docker run \
  --privileged \
  --rm \
  -it \
  --name t2iso \
  -v "$(pwd)":/repo \
  -v /sys/fs/cgroup:/sys/fs/cgroup:rw \
  -v /lib/modules:/lib/modules \
  -v /dev:/dev \
  ${DOCKER_IMAGE} \
  /sbin/init
