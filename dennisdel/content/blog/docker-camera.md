---
title: Uploading Nest camera video to Azure Storage
type: blog
date: 2018-01-13T22:04:10+00:00
slug: docker-camera
news_keywords: [ "nest", "camera", "how-to", "docker", "azure", "storage" ]
images: ["https://dennisdel.com/images/postmedia/docker-camera/whale.jpeg"]
---

![Whale breaching water](/images/postmedia/docker-camera/whale.jpeg)

(_Image sourced [from StockIO.com](https://www.stockio.com/free-photo/animal-475)._)

Last weekend I [hacked together a solution that allows Nest stream capture](https://dennisdel.com/blog/nest/) locally. This weekend I got a chance to improve it a bit and make the entire solution cloud-ready.

[Check out the changes on GitHub](https://github.com/dend/foggycam/releases/tag/1.0). There is a number of changes in this release:

* _Parallelization of camera captures._ If you have many cameras, you will not experience a video lag in your captures - previously, the streams were chained, now they work at the same time for different devices, so videos are produced simultaneously.
* _High-quality images._ Image quality is much better now, compared to the previous version. Less pixelated means now you have a better idea who is moving around in front of your camera.
* _Support for Azure Storage upload._ Now, you can capture videos and upload them to Azure Storage.
* _Support for container deploy._ `foggycam` now supports Docker out-of-the-box, so you no longer have to clone the tooling every time you need to run it - just package a Docker container, and push it whenever you need it.
* _Support for pre-installed `ffmpeg`._ If you have `ffmpeg` installed on your Linux or Mac box, we identify it and use it, so you no longer have to manually install and copy it locally if you don't want to.

## Azure Storage Functionality

The interesting part about this update, at least in my own humble opinion, is the support for Azure Storage uploads and the Docker-ization of the deployment. If you don't yet have an Azure account, make sure you sign up ([free trial available](https://azure.microsoft.com/en-us/free/)) before you take advantage of that functionality.

The upload happens with the help of the [Azure Storage Python SDK](https://github.com/Azure/azure-storage-python):

```python
"""Provides a way to upload video content to Azure Storage."""

from azure.storage.blob import BlockBlobService, ContentSettings

class AzureStorageProvider(object):
    """Class that facilitates connection to Azure Storage."""

    def upload_video(self, account_name='', sas_token='', container='', blob='', path=''):
        """Upload video to the provided account."""

        block_blob_service = None

        if account_name and sas_token and container and blob:
            block_blob_service = BlockBlobService(account_name=account_name, sas_token=sas_token)
            containers = block_blob_service.list_containers()

            if container not in containers:
                block_blob_service.create_container(container)
        else:
            print 'ERROR: No account credentials for Azure Storage specified.'

        block_blob_service.create_blob_from_path(
            container,
            blob,
            path,
            content_settings=ContentSettings(content_type='video/mp4')
        )
```

The `sas_token` and `account_name` are read in from the config file, and then for each registered camera a new blob container is created. Once the video is generated, a setting is read in from the configuration file that determines whether the video should be pushed to Azure Storage.

>**NOTE:** Currently the code does no checks on Azure Storage usage, so make sure you are aware of your account limits.

## Container Deployment

You can now deploy `foggycam` with the help of [Docker containers](https://www.docker.com/what-container). When you clone the repo, you will now gain access to a [Dockerfile](https://docs.docker.com/engine/reference/builder/). Make sure you set all the values in the `config.json` file before you build the container. 

When ready to build it, simply call:

```
docker build -t foggycam_image .
```

This will build the image. Once the build is complete, you can run:

```
docker run -it foggycam_image 
```

The cool thing about having a Docker image is that you can also deploy it to Azure and have it run outside the boundaries of your local machine - that also ensures that the capture happens even when your machine is not running.

If you already have the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) installed, run the following command to authenticate:

```
az login
```

Through the portal, create a new [Azure Resource Group](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-overview) and an [Azure Container Registry](https://azure.microsoft.com/en-ca/services/container-registry/) instance. Once done, tag the image you just created with the URL to the container instance:

```
docker tag foggycam_image <azure_cr_instance>.azurecr.io/infrastructure     
```

Now, make sure you log in to the container registry via the terminal:

```
az acr login --name <azure_cr_instance> 
```

Push the freshly-tagged image to the container registry:

```
docker push <azure_cr_instance>.azurecr.io/infrastructure
```

And finally, provision the [Azure Container Instance](https://docs.microsoft.com/en-us/azure/container-instances/container-instances-quickstart#pull-the-container-logs):

```
az container create --resource-group <your_resource_group> --name foggycam-container --image <azure_cr_instance>.azurecr.io/infrastructure:latest --ip-address public --port 80 --registry-password <azure_cr_instance_password>
```

Once the container instance is running, the video content will be generated and uploaded to the associated storage account.

>**NOTE:** Something to keep in mind is that in the context of this work, I have not put in place any explicit security boundaries - as you deploy containers, consider the fact that you are deploying a configuration file with the credentials into the container. I recommend using a tool like [Azure Key Vault](https://azure.microsoft.com/en-ca/services/key-vault/) to control key access.