#!/bin/bash

set -eu -o pipefail

DOCKER_IMAGE_NAME=t2-iso-builder
DOCKER_IMAGE_TAG=latest
DOCKER_IMAGE=${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} 

docker build -t ${DOCKER_IMAGE} -f Dockerfile .

# docker pull ${DOCKER_IMAGE}
docker run \
  --rm \
  -it \
  --cap-add=SYS_ADMIN \
  --cap-add=MKNOD \
  --device /dev/fuse \
  --security-opt apparmor=unconfined \
  -v "$(pwd)":/repo \
  ${DOCKER_IMAGE}
