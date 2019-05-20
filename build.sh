#!/usr/bin/env bash

function die() {
  echo "Error: $1"
  exit 1
}

# build the Docker image for building some of the Silverpeas projects
if [[ $# -eq 2 ]]; then
  docker build \
    --build-arg WILDFLY_VERSION=$2 \
    -t silverpeas/silverbuild:$1 \
    .
elif [[ $# -eq 0 ]]; then
  docker build \
    -t silverpeas/silverbuild:latest \
    .
else
  die "build.sh [SILVERPEAS_VERSION WILDFLY_VERSION]"
fi

