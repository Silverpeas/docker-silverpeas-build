# docker-silverpeas-build

A `Dockerfile` that produces a Docker image ready to build a [Silverpeas 6](https://www.silverpeas.org) 
project.

Such an image is dedicated to be used by our own integration continuous service for building 
different projects and also for deploying the built software artifacts into our own Nexus server.

## Image creation

To create an image to build the latest version in development of Silverpeas, just do:

	$ ./build.sh

this will generate an image with the tag `silverpeas/silverbuild:latest`, meaning that this image
is for building the latest snapshot versions of Silverpeas.

The distribution of the Wildfly application server targeted by the future version of Silverpeas is 
explicitly defined in `Dockerfile`. Specifying such a distribution is very important because the 
integration tests are ran within it, and hence a specific distribution of Wildfly, prepared for 
running the integration tests, will be downloaded in the image creation. (Such a prepared 
distribution has to be available in our server.) 

Beside that, to create an image for building a given version of Silverpeas 6, and hence targeted a
specific release of Wildfly, you have to pass them as arguments of the script:

	$ ./build.sh -v 6.0 10.1.0

This will generate a Docker image with the tag `silverpeas/silverbuild:6.0` to work on Silverpeas 6.0
and with Wildfly 10.1.0. The version of Silverpeas passed as argument isn't important;
it just indicates for which version of Silverpeas this image is and tags the image with that version. 
But the version of Wildfly passed as argument is important because a Wildfly distribution preconfigured 
for the integration tests will be downloaded and in general, for each version of Silverpeas 
(stable or in-development version) matches a given version of Wildfly.

## Container running

To run a container `silverbuild` from the lastest version of the image, just do:

	$ ./run.sh

or for a given version, say 6.0:

	$ ./run.sh 6.0

The script will link the following directories and files in your home `.ssh`, `.gnupg`, 
`.m2/settings.xml`, `.m2/settings-security.xml` and `.gitconfig` to those of the default user in the
container (that is root because this is what it's expected by a CI service). By doing so, any build 
performed within the container will be able to fetch dependencies, to sign the source code, to deploy 
the software artifacts into a Nexus server and to commit and push into a Git remote repository. 

If you requirement is just to build a Silverpeas project (id est compiling and testing), then
you don't have to link these directories and files. You can then run a container as
following:

	$ docker run -it --name silverbuild silverpeas/silverbuild /bin/bash
 
If your requirement is also to commit and push into a remote Git repository, then link your
`.gitconfig` file as following:

	$ docker run -it -v "$HOME"/.gitconfig:/home/silveruser/.gitconfig --name silverbuild silverpeas/silverbuild /bin/bash



