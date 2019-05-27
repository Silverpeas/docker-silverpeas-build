#!/usr/bin/env bash

# run the silverpeas build image by linking the required volumes for signing and deploying built artifacts.
docker run -it -v "$HOME"/.m2/settings.xml:/root/.m2/settings.xml \
  -v "$HOME"/.m2/settings-security.xml:/root/.m2/settings-security.xml \
  -v "$HOME"/.gitconfig:/root/.gitconfig \
  -v "$HOME"/.ssh:/root/.ssh \
  -v "$HOME"/.gnupg:/root/.gnupg \
  --name silverbuild \
  silverpeas/silverbuild:6.0 /bin/bash