#!/bin/bash -e

############################################
# HOMESEER (V4) LINUX - DOCKER BUILD SCRIPT
############################################

# default mode
MODE="load"

# parse command line argument --mode
while [[ $# -gt 0 ]]; do
    case $1 in
        --mode)
            MODE="$2"
            shift 2
            ;;
        *)
            # pass through unknown args to docker buildx
            EXTRA_ARGS+=("$1")
            shift
            ;;
    esac
done

# use buildx to create a new builder instance; if needed
docker buildx create --driver-opt env.BUILDKIT_STEP_LOG_MAX_SIZE=10485760   \
                     --driver-opt env.BUILDKIT_STEP_LOG_MAX_SPEED=100000000 \
                     --use --name homeseer-builder || true;

build () {
  VERSION=$1
  DOWNLOAD=$2
  TAGS=$3
  ARGS=$4

  # determine platform and output flag based on mode
  if [ "$MODE" == "load" ]; then
      PLATFORM="linux/amd64"
      OUTPUT="--load"
  elif [ "$MODE" == "push" ]; then
      PLATFORM="linux/amd64,linux/arm64"
      OUTPUT="--push"
  else
      echo "Invalid mode: $MODE. Use 'load' or 'push'."
      exit 1
  fi

  echo
  echo "Building HomeSeer $VERSION ($MODE mode) on platform(s): $PLATFORM"
  echo

  docker buildx build \
    --build-arg BUILDDATE="$(date -u +'%Y-%m-%dT%H:%M:%SZ')" \
    --build-arg VERSION="$VERSION" \
    --build-arg DOWNLOAD="$DOWNLOAD" \
    --platform $PLATFORM \
    $OUTPUT \
    --tag spudwebb/homeseer:$VERSION \
    $TAGS \
    . $ARGS
}

# latest beta build
build "4.2.22.94" "https://homeseer.com/updates4/linux_4_2_22_94.tar.gz" "--tag spudwebb/homeseer:beta" "${EXTRA_ARGS[@]}"

# latest release build
build "4.2.22.0" "https://homeseer.com/updates4/linux_4_2_22_0.tar.gz" "--tag spudwebb/homeseer:latest" "${EXTRA_ARGS[@]}"
