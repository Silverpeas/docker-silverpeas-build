#
# This Dockerfile is dedicated to our CI service to build our projects driven by Maven or Gradle.
# The builds are performed as the user silverbuild and not as root. So, it is required the user id
# and group id are those of the user as whom the CI service is running.
#
FROM ubuntu:jammy

LABEL name="Silverpeas Build" description="An image to build a Silverpeas project" vendor="Silverpeas" version=latest build=1
MAINTAINER Miguel Moquillon "miguel.moquillon@silverpeas.org"

ENV TERM=xterm

# Non generic time zone. Tests should succeed whatever the time zone.
ENV TZ=Europe/Paris

# Parameters whose values are required for the tests to succeed
ARG WILDFLY_VERSION=26.1.3
ARG JAVA_VERSION=11
ARG SONAR_JAVA_VERSION=17
ARG DEFAULT_LOCALE=fr_FR.UTF-8
ARG MAVEN_VERSION=3.9.8
ARG MAVEN_SHA=7d171def9b85846bf757a2cec94b7529371068a0670df14682447224e57983528e97a6d1b850327e4ca02b139abaab7fcb93c4315119e6f0ffb3f0cbc0d0b9a2
ARG NODEJS_VERSION=20

ARG DEBIAN_FRONTEND=noninteractive

# Users to use by the CI service to build projects. Required if you whish to avoid some security
# restrictions. Should be the user and group as whom the CI service is running.
ARG USER_ID=111
ARG GROUP_ID=119

COPY src/maven-deps.zip /tmp/

RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-utils \
    iputils-ping \
    vim \
    curl \
    git \
    openssh-client \
    gnupg \
    locales \
    language-pack-en \
    language-pack-fr \
    tzdata \
    procps \
    net-tools \
    zip \
    unzip \
    openjdk-${JAVA_VERSION}-jdk \
    openjdk-${SONAR_JAVA_VERSION}-jdk \
    ffmpeg \
    imagemagick \
    ghostscript \
    libreoffice-writer \
    libreoffice-calc \
    libreoffice-impress \
    gpgv \
    groovy \
  && groupadd -g ${GROUP_ID} silverbuild \
  && useradd -u ${USER_ID} -g ${GROUP_ID} -d /home/silverbuild -s /bin/bash -m silverbuild \
  && curl -sL https://deb.nodesource.com/setup_${NODEJS_VERSION}.x | bash - \
  && apt-get install -y nodejs \
  && rm -rf /var/lib/apt/lists/* \
  && update-ca-certificates -f \
  && mkdir -p /usr/share/maven /usr/share/maven/ref \
  && curl -fsSL -o /tmp/apache-maven.tar.gz https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
  && echo "${MAVEN_SHA}  /tmp/apache-maven.tar.gz" | sha512sum -c - \
  && tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 \
  && rm -f /tmp/apache-maven.tar.gz \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn \
  && unzip /tmp/maven-deps.zip -d /home/silverbuild/ \
  && curl -fsSL -o /tmp/swftools-bin-0.9.2.zip https://www.silverpeas.org/files/swftools-bin-0.9.2.zip \
  && echo 'd40bd091c84bde2872f2733a3c767b3a686c8e8477a3af3a96ef347cf05c5e43 *swftools-bin-0.9.2.zip' | sha256sum - \
  && unzip /tmp/swftools-bin-0.9.2.zip -d / \
  && curl -fsSL -o /tmp/pdf2json-bin-0.68.zip https://www.silverpeas.org/files/pdf2json-bin-0.68.zip \
  && echo 'eec849cdd75224f9d44c0999ed1fbe8764a773d8ab0cf7fff4bf922ab81c9f84 *pdf2json-bin-0.68.zip' | sha256sum - \
  && unzip /tmp/pdf2json-bin-0.68.zip -d / \
  && curl -fsSL -o /tmp/wildfly-${WILDFLY_VERSION}.Final.FOR-TESTS.zip https://www.silverpeas.org/files/wildfly-${WILDFLY_VERSION}.Final.FOR-TESTS.zip \
  && mkdir /opt/wildfly-for-tests \
  && unzip /tmp/wildfly-${WILDFLY_VERSION}.Final.FOR-TESTS.zip -d /opt/wildfly-for-tests/ \
  && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
  && echo "fr_FR.UTF-8 UTF-8" >> /etc/locale.gen \
  && echo "de_DE.UTF-8 UTF-8" >> /etc/locale.gen \
  && locale-gen \
  && update-locale LANG=${DEFAULT_LOCALE} LANGUAGE=${DEFAULT_LOCALE} LC_ALL=${DEFAULT_LOCALE}

COPY src/settings.xml /home/silverbuild/.m2/

RUN chown -R silverbuild:silverbuild /home/silverbuild \
  && chown -R silverbuild:silverbuild /opt/wildfly-for-tests

ENV LANG ${DEFAULT_LOCALE}
ENV LANGUAGE ${DEFAULT_LOCALE}
ENV LC_ALL ${DEFAULT_LOCALE}
ENV MAVEN_HOME /usr/share/maven
ENV JAVA_HOME /usr/lib/jvm/java-${JAVA_VERSION}-openjdk-amd64
ENV SONAR_JDK_HOME /usr/lib/jvm/java-${SONAR_JAVA_VERSION}-openjdk-amd64

# Ensure signals are forwarded to the JVM process correctly for graceful shutdown
ENV LAUNCH_JBOSS_IN_BACKGROUND true

USER silverbuild

# The GPG and SSL keys to use for respectively signing and then deploying the built artifact to
# our Nexus server have to to be provided by an outside directory; therefore the below definition
# of volumes.
# WARNING: You have to link also the below files or directories in order to be able to deploy the
# build results and to push commits:
# - /home/silverbuild/.m2/settings.xml and /home/silverbuild/.m2/settings-security.xml files
# with the ones of the CI service user in order to sign and to deploy the artifact with
# Maven. In these files the GPG key, the SSL passphrase as well as the remote servers must be defined.
# - /home/silverbuild/.m2/.gitconfig file with the ones of the CI service user in order to be able
# to push any commits.
VOLUME ["/home/silverbuild/.ssh", "/home/silverbuild/.gnupg"]
