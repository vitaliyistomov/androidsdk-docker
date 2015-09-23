# Introduction

Dockerfile for creating a container with Android SDK. Kind of a build slave.

# Usage

To create a container you need to *cd* to the folder with the dockerfile and run the following:

```
docker build --no-cache=true -t inbot/android-build-env .
```

This will create a container for you with the Android SDK, all the basic tools, platform-tools, build-tools and the latest platform.

The build is organised via shared folder with a host machine. This complicates things a bit, but good things is that it has to be done only once. Let me explain it step by step. Here is how you can trigger a build:

```
GROUP=$(id -gn)
docker run -e DEV_UID=$UID -e DEV_GROUPS=$GROUPS -e DEV_USER=$USER -e DEV_GROUP=$GROUP -v $WORKDIR:/android-build inbot/android-build-env
```

What we are doing here is simply transferring the uid and guid to the container, so it will be able to create a clone of the CI user in the container, to perform all the operations from cloned user in the container. This will let CI environment tread the files, created by the container as it's own and there will be no problem to remove when CI will be wiping the build environment.

To adapt this container for your needs, you need to modify the last line, which is calling for us our build script from the app's repository as a cloned CI user:

```
*./build.sh ${ANDROID_HOME}*
```

# Pitfalls

There is an issue with an update for Android SDK component, which does not have a version. For example:

```
android update sdk --no-ui --all --filter tools,platform-tools
```

There is no way for Docker to figure it out - it will just skip this line and use cached result of it's execution with an old version.

Quick fix here is to recreate the container if this happens. I will try to look for some more civilised solution when time allows.
