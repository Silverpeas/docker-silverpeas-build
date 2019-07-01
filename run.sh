#!/usr/bin/env bash

function die() {
  echo "Error: $1"
  exit 1
}

if [[ $# -eq 1 ]]; then
  image_version=$1
else
  image_version=latest
fi

# run the silverpeas build image by linking the required volumes for signing and deploying built artifacts.
docker run -it -u silverbuild:silverbuild \
  -v "$HOME"/.m2/settings.xml:/home/silverbuild/.m2/settings.xml \
  -v "$HOME"/.m2/settings-security.xml:/home/silverbuild/.m2/settings-security.xml \
  -v "$HOME"/.gitconfig:/home/silverbuild/.gitconfig \
  -v "$HOME"/.ssh:/home/silverbuild/.ssh \
  -v "$HOME"/.gnupg:/home/silverbuild/.gnupg \
  --name silverbuild \
  silverpeas/silverbuild:${image_version} /bin/bash