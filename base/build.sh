#!/bin/bash -e

############################################
# HOMESEER (V4) LINUX - DOCKER BUILD SCRIPT
############################################


# docker image version
VERSION="1.0"

echo
echo "**********************************************************************"
echo "* BUILDING HOMESEER LINUX BASE DOCKER IMAGE                          *"
echo "**********************************************************************"
echo

# use buildx to create a new builder instance; if needed
docker buildx create --driver-opt env.BUILDKIT_STEP_LOG_MAX_SIZE=10485760   \
                     --driver-opt env.BUILDKIT_STEP_LOG_MAX_SPEED=100000000 \
                     --use --name homeseer-builder || true;

# perform multi-arch platform image builds; push the resulting image to the DockerHub repository
docker buildx build \
  --build-arg BUILDDATE="$(date -u +'%Y-%m-%dT%H:%M:%SZ')" \
  --build-arg VERSION="$VERSION" \
  --platform linux/amd64,linux/arm64 \
  --push \
  --tag homeseer/base:$VERSION \
  --tag homeseer/base:latest \
  . $@
