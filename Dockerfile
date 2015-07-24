FROM ubuntu:14.04.2

# copied from
#MAINTAINER Jacek Marchwicki "jacek.marchwicki@gmail.com"
MAINTAINER Inbot "info@inbot.io"

RUN echo "deb mirror://mirrors.ubuntu.com/mirrors.txt trusty main restricted universe\n  \
deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-updates main restricted universe\n  \
deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-backports main restricted universe\n  \
deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-security main restricted universe" > /etc/apt/sources.list

RUN apt-get update && apt-get -y upgrade

# Install java7
RUN apt-get install -y software-properties-common && add-apt-repository -y ppa:webupd8team/java && apt-get update
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN apt-get install -y oracle-java8-installer

# Install Deps
RUN dpkg --add-architecture i386 && apt-get update && apt-get install -y --force-yes expect git wget libc6-i386 lib32stdc++6 lib32gcc1 lib32ncurses5 lib32z1 python curl

# Install Android SDK
RUN cd /opt && wget --output-document=android-sdk.tgz --quiet http://dl.google.com/android/android-sdk_r24.3.3-linux.tgz && tar xzf android-sdk.tgz && rm -f android-sdk.tgz && chown -R root.root android-sdk-linux

# Setup environment
ENV ANDROID_HOME /opt/android-sdk-linux
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools

# Install sdk elements
RUN (while [ 1 ]; do sleep 1; echo y; done ) | android update sdk --no-ui --filter tool
RUN (while [ 1 ]; do sleep 1; echo y; done ) | android update sdk --no-ui --filter platform-tools
RUN (while [ 1 ]; do sleep 1; echo y; done ) | android update sdk --no-ui --filter android-22
RUN (while [ 1 ]; do sleep 1; echo y; done ) | android update sdk --no-ui --filter build-tools-22.0.1
RUN (while [ 1 ]; do sleep 1; echo y; done ) | android update sdk --no-ui --filter sys-img-x86_64-android-22
RUN (while [ 1 ]; do sleep 1; echo y; done ) | android update sdk --no-ui --filter extra-android-m2repository,extra-google-m2repository

# Create emulator
#RUN echo "no" | android create avd \
#                --force \
#                --device "Nexus 5" \
#                --name test \
#                --target android-22 \
#                --abi armeabi-v7a \
#                --skin WVGA800 \
#                --sdcard 512M

# Cleaning
RUN apt-get clean

VOLUME ["/android-build"]
WORKDIR /android-build

# Create jenkins user and run the build script from it's name
# This ensures, that all temporary and resulting binaries will have jenkins
# user as owner and will not break workspace cleanup procedures.
CMD groupadd --gid ${DEV_GROUPS} ${DEV_GROUP} && \
 useradd --gid ${DEV_GROUPS} --uid ${DEV_UID} ${DEV_USER} && \
 mkdir /home/${DEV_USER} && \
 chown ${DEV_USER}:${DEV_GROUP} /home/${DEV_USER} && \
 sudo -H -u ${DEV_USER} bash -c "./build.sh ${ANDROID_HOME}"
