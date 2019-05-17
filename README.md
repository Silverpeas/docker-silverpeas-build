# docker-silverpeas-build

A `Dockerfile` that produces a Docker image ready to build a [Silverpeas 6](http://www.silverpeas.org) 
project.

Such an image is dedicated to be used by our own integration continuous service for building 
different projects and also for deploying the built software artifacts into our own Nexus server.

Nevertheless, this image can also be used for development on one or more Silverpeas projects. For
doing, a more explanation is provided in the Container running section.

## Image creation

To create an image, just do:

	$ ./build.sh

this will build an image to work on the latest version of Silverpeas as defined in the `Dockerfile` 
with the tag `silverpeas/silverbuild:latest`.

Otherwise, to create an image to build a given version of Silverpeas 6, you have to specify as argument 
both the version of Silverpeas followed by the exact version of Wildfly used by this version:

	$ ./build.sh -v 6.0 10.1.0

This will build a Docker image to work on Silverpeas 6.0 and with Wildfly 10.1.0 with 
the tag `silverpeas/silverbuild:6.0`. The version of Silverpeas passed as argument isn't important;
it just indicates for which version of Silverpeas this image is and tag the image with that version. 
But the version of Wildfly passed as argument is important because a Wildfly distribution preconfigured 
for the integration tests will be downloaded and in general, for each version of Silverpeas 
(stable or in-development version) matches a given version of Wildfly.

In the case you want to use the image for bootstrapping a container dedicated to the
development of one or more Silverpeas projects, you have to check the user identifier of your
account is 1000. This identifier is the one of the default user account used in the image. By having 
the same user identifier than the user in the container, you will be able to share
the code between it and your host. (Otherwise, you will risk to have permission denied errors.)
For any other user identifier, you can specify it while building the image as following:

	$ ./build.sh -u 1026

or

	$ ./build.sh -v 6.0 10.1.0 -u 1026

## Container running

To run a container `silverbuild` from the lastest version of the image, just do:

	$ ./run.sh

or for a given version, say 6.0:

	$ ./run.sh 6.0

The script will link the following directories and files in your home `.ssh`, `.gnupg`, 
`.m2/settings.xml`, `.m2/settings-security.xml` and `.gitconfig` to those of the default user in the
container. By doing so, any build performed within the container will be able to fetch dependencies, 
to sign the source code, to deploy the software artifacts into a Nexus server and to commit and
push into a Git remote repository. 

If you requirement is just to build a Silverpeas project (id est compiling and testing), then
you don't have to link these directories and files. You can then run a container as
following:

	$ docker run -it --name silverbuild silverpeas/silverbuild /bin/bash
 
If your requirement is also to commit and push into a remote Git repository, then link your
`.gitconfig` file as following:

	$ docker run -it -v "$HOME"/.gitconfig:/home/silveruser/.gitconfig --name silverbuild silverpeas/silverbuild /bin/bash

In the case the container is dedicated to be used in your development process, the don't forget to
link your own directory containing the different Silverpeas projects you are working on:

	$ docker run -it \
	      -v "$HOME"/Projects:/home/silveruser/Projects \ 
	      -v "$HOME"/.gitconfig:/home/silveruser/.gitconfig \
	      --name silverbuild silverpeas/silverbuild /bin/bash

