#!/bin/bash
set -e

DOCKER_IMAGE="t2-iso-builder:latest"

echo "=== Building ISO Builder Docker image ==="
docker build -t $DOCKER_IMAGE -f dockerfile .

echo "=== Running ISO Builder container ==="
docker run \
  --rm \
  -it \
  --cap-add=SYS_ADMIN \
  --device /dev/fuse \
  --security-opt apparmor=unconfined \
  -v "$(pwd)":/repo \
  $DOCKER_IMAGE \
  bash -c "cd /repo && ./build.sh"