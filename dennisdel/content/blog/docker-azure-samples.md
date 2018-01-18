---
title: Validating Samples with Docker & Azure Container Registry
type: blog
date: 2017-06-05T22:04:10+00:00
---

If you read one of the latest [Ars Technica pieces](https://arstechnica.com/information-technology/2017/05/microsofts-renewed-embrace-of-developers-developers-developers-developers/) about how Microsoft renewed its strategy on embracing developers across the board, you might've stumbled across this little tidbit:

> Sample code is all built using the continuous integration features of Team Services to ensure that it's correct and functional.

Indeed, we are on a mission to make sure that all sample code that we ship is validated against a matrix of requirements and that it works on all platforms where it is supposed to work. So how do we do this?

![Containers](/images/postmedia/docker-azure-samples/containers.jpg)

As an example for the purpose of this blog post, I will take one of my favorite areas - .NET. For .NET, we host a batch of samples in the [documentation repository on GitHub](https://github.com/dotnet/docs). Those are all located in the `/samples` folder. The reason those reside there is because all of them are in one way or another referenced directly from the .NET documentation, which makes it convenient to organize and maintain. As a starting point, we looked at what is our focus there - and that is cross-platform code. 

We want to make sure that users can be successful with the .NET stack across the board - on Linux, Mac and Windows. So it's clear that our validation matrix will span quite of a surface. With that in mind, we want to follow a simple principle - while the sample is validated, it should create reproducible results. That means that if anything goes wrong, we need to be able to quickly reproduce the problem without spending much time understandint the exact environment where the sample ran. The answer to that problem? [Docker](https://www.docker.com/).

![Docker Logo](/images/postmedia/docker-azure-samples/docker_logo.png)

If you are new to Docker, I highly recommend you start with the [official Docker Training](https://training.docker.com/introduction-to-docker).

What Docker offers us is the ability to run validation inside containers, which ultimately translates into us having the option to "local-build" a sample later in the exact shape it was built in the Continuous Integration (CI) pipeline.

But before we get into the details, let's break down the pieces of the system that we need in place:

* **A CI pipeline.** [Visual Studio Team Services](https://www.visualstudio.com/team-services/) is free, and offers [hosted build agents](https://www.visualstudio.com/en-us/docs/build/concepts/agents/hosted), so that seems like a good place to start.
* **A Docker registry**. If you have an [Azure](https://azure.microsoft.com/en-us/) account (and you should totally [get one if you don't](https://azure.microsoft.com/en-us/free/)), you can use the [Azure Container Registry](https://docs.microsoft.com/en-us/azure/container-registry/) as your foundation. A registry in this case is used as a private store for container images that we will be using. Of course you can always [spin up your own](https://docs.docker.com/registry/).
* **A storage account**. I personally use [Azure Storage](https://docs.microsoft.com/en-us/azure/storage/), but just like with any other piece in this scenario, you can substitute it for something that works for you. This will be used later to drop modified build images.

Following the steps below, you can closely replicate our own sample testing behavior.

## Container Infra Set Up

Let's start by setting up a new Azure Container Registry. You can do so through the [Azure Portal](https://portal.azure.com).

![New Container Registry](/images/postmedia/docker-azure-samples/portal-new-cr.png)

When you create a new registry, you will be guided through the standard Azure wizard, where you can specify which resource group it will belong to and what storage account will be associated with it. I recommend you keep this storage account dedicated to the container registry itself and nothing else.

Once the container registry is created, you can start pushing new images into it! Remember, because we are operating in the .NET world for this blog post, we will need some images that have the .NET SDK installed on them.

Start by logging in to the container registry:

```bash
docker login {insert_registry}.azurecr.io -u {username} -p {password}
```

With Docker on your client machine, you will need to pull an existing .NET-ready image. Lucky for us, [Microsoft already provides some](https://hub.docker.com/r/microsoft/dotnet/), so you can just do this:

```bash
docker pull microsoft/dotnet:2.0-sdk  
```

Now you have a local image. You will need to tag it and upload it to your newly-created container registry in Azure (or one you self-manage). Start by tagging it:

```bash
docker tag microsoft/dotnet:2.0-sdk {insert_registry}.azurecr.io/platforms/netcoresdk:2.0-sdk
```

Of course, you need to substitute `{insert_registry}` with the name of your container registry (or, like I mentioned a couple of times - substitute the entire thing with the right URL you are managing if that is the case).

You are ready to [push the image to your registry](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-get-started-docker-cli):

```bash
docker push {insert_registry}.azurecr.io/platforms/netcoresdk:2.0-sdk     
```

Once the push completes, you will notice it in the portal, in the **Repository** section of the view:

![Images](/images/postmedia/docker-azure-samples/containers.png)

## Build Set Up

At this point, you have the base container infrastructure ready. Now it's time to set up the build system, so that you can actually test real samples. Assuming that you created a free Visual Studio Team Services account and have a project, open the **Builds** view.

![Builds](/images/postmedia/docker-azure-samples/builds.png)

Create a new **empty build definition** - we are designing each step individually.

### Step 1: Get Sources

This step should be created in VSTS by default. Make sure you connect a code repository where you keep the samples - authentication methods will be provided right there, so you can log in both to GitHub and VSTS, if necessary. This is the code that will be cloned locally to the build agent every time a build kicks off.

### Step 2: Provision a Docker Image

You will now need to create a local copy of a Docker image you pushed into your container registry. For convenience purposes, I wrote a little script that can be triggered through a **Shell build step**:

```bash

DOCKER_UN="$1"
DOCKER_PW="$2"
WORK_FOLDER="$3"
TARGET_IMAGE="$4"

echo $WORK_FOLDER >> "$BUILD_REPOSITORY_LOCALPATH/buildtarget.txt"

docker login -u "$DOCKER_UN" -p "$DOCKER_PW" {insert_registry}.azurecr.io

docker pull $TARGET_IMAGE

echo "Creating container for pre-provisioning..."
docker create --name builder $TARGET_IMAGE

echo "Copying samples to container..."
docker cp "$BUILD_REPOSITORY_LOCALPATH/samples/." builder:/samples/
docker cp "$BUILD_REPOSITORY_LOCALPATH/ci-scripts/buildsamples.sh" builder:buildsamples.sh
docker cp "$BUILD_REPOSITORY_LOCALPATH/buildtarget.txt" builder:buildtarget.txt

echo "Committing changes..."
docker commit builder $TARGET_IMAGE

docker run --name newbuilder --rm -w $WORK_FOLDER $TARGET_IMAGE bash -c 'sh ../../buildsamples.sh'
```

Here's what's happening above.

1. Script parameters are read, that include the **container registry username**, **container registry password**, **target work folder** and **target image**.
2. The work folder is stored in a file inside the local source root (`$BUILD_REPOSITORY_LOCALPATH`) so that we can reference it later.
3. The script authenticates against the container registry with the provided credentials (stored previously in secure variables - we'll get there).
4. The target image is pulled locally.
5. A new container is created based on the target image.
6. Sample code, as well as a **sample building script** (we'll get to it in a bit as well) and the **file containing the name of the working folder** are copied into the container.
7. Changes are commited to the container.
8. A new container based on the just-modified image is being ran.

All in all, the steps above simply ensure that we copy the desired sample code inside the container and trigger a build script within it. Remember - we want to make sure that samples create reproducible results, so we need to execute them exclusively within the container, with all the prerequisites (including the build script).

As of `buildsamples.sh` - it's a simple shell script that ensures we find all `*.csproj` files in the target working folder, restores all NuGet packages and builds the code:

```bash

#!/bin/sh

TARGET_FOLDER=`cat ../../buildtarget.txt`

for sample in $(find $TARGET_FOLDER -name *.csproj); do dotnet restore $sample; dotnet build $sample; done
```

The build step configuration includes all the variables that we read in the previous step:

![Builds](/images/postmedia/docker-azure-samples/script-configuration.png)

`$(DOCKERUN)` and `$(DOCKERPW)` are secure variables that store the container registry username and password - those can be declared in the **Variables** tab in the build definition:

![Variables](/images/postmedia/docker-azure-samples/variable-config.png)

Notice that the second and third parameters, respectively, are the **working folder** and **target image**.

### Step 3: Take a snapshot of the modified image

Again, I am using a shell script task, that targets a `preserveimage.sh` file:

```bash
IMAGE="$1"

mkdir "$BUILD_REPOSITORY_LOCALPATH/buildimage"
docker save -o $BUILD_REPOSITORY_LOCALPATH/buildimage/$BUILD_BUILDNUMBER-dotnet.tar "$IMAGE"
```

All this step does is it takes the image identifier (already pulled locally and modified) and [exports it](https://docs.docker.com/engine/reference/commandline/save/) into a directory within the agent.

### Step 4: Install Azure CLI

I am using a [VSTS Linux Hosted Agent](https://www.visualstudio.com/en-us/docs/build/concepts/agents/hosted), where the Azure CLI is not installed by default, which means that it should be a step done by the CI pipeline maintainer. This is relatively easy to do, however, it does not currently support [Azure CLI 2.0](https://docs.microsoft.com/en-us/cli/azure/overview) out-of-the-box, so we have to fall back on [Azure CLI 1.0](https://docs.microsoft.com/en-us/azure/cli-install-nodejs). 

I wrote a small shell script to install it via npm:

```bash
set -x
npm install -g azure-cli
```

### Step 5: Upload the image to Azure Storage

Last but not least, there is a shell script that takes the local image and uploads it directly to Azure Storage:

```bash
export AZURE_STORAGE_CONNECTION_STRING="$1"

CONTAINER_NAME=constructors-images
SOURCE_FOLDER="$BUILD_REPOSITORY_LOCALPATH/buildimage/*"

CONTAINER_LIST=$(azure storage container list)

if [[ $CONTAINER_LIST == *$CONTAINER_NAME* ]]; then
  echo "It's there!"
else
  azure storage container create "$CONTAINER_NAME"
fi

ls "$BUILD_REPOSITORY_LOCALPATH/buildimage"

for file in $SOURCE_FOLDER; do
  azure storage blob upload "$file" "$CONTAINER_NAME" "$BUILD_BUILDNUMBER"
done
```

This should be integrated within an [Azure CLI task](https://github.com/Microsoft/vsts-tasks/blob/master/Tasks/AzureCLI/Readme.md) set to version **0.*** - that way you will be relying on the correct set of commands (between 1.0 and 2.0 versions of the CLI `azure` became `az`).

What the script above does is get the storage connection string (you can obtain it from the portal) that is passed to the step as an argument (similarly to how we read the container registry credentials from secure variables), verifies and creates (if necessary) a new storage container, and subsequently uploads the image from the `/buildimage` folder to the blob store.

### Testing things out

As long as you set everything up correctly, you should have a ready-to-go build definition that will build the sample and upload the resulting image to the blob store. 

You need to make sure to configure the actual sample build step to continue on error, that way uploading your image to the store even if the build failed, so that you can diagnose it.

Once your image is uploaded, you can pull it locally via the [Storage Explorer](http://storageexplorer.com/) and then use the following commands to load it locally:

```bash
docker load -i {image_name}.tar   
```

And to run it (use `docker images` to verify that the image is loaded):

```bash
docker run -i -t {image_id} /bin/bash   
```
The build script is already in the image, so you can just start your local build via `sh buildsamples.sh`.