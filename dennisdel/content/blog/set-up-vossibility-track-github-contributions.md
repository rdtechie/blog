---
title: Setting up Vossibility Stack to Track GitHub Community Contributions
type: blog
date: 2016-10-24T04:43:54+00:00
---

One of the key parts of my job as a Program Manager on the [docs.microsoft.com][1] team is to assess community contributions across different documentation repositories and areas. That might appear to be a very complicated task, and as we go, I will document more on the process. This post, however, is dedicated to setting up the core environment to make the task somewhat easy.

## Get Vossibility and all dependencies

[Vossibility-stack][2] is a product published by [Arnaud Porterie][3] of [Docker][4]. To get started, simply clone the repository with all the dependencies. Personally, because I plan on adding some modifications that are specific to my field of work, I forked the repo first and then cloned.

Post-fork, I just used the [GitHub Desktop][5] client for Mac to get the bits locally.

![GitHub for Mac](/images/postmedia/set-up-vissibility-track-github-contributions/Screenshot-2016-10-23-18.04.50.png)

The stack relies on Docker, so the next obvious step would be to install the [Docker Toolbox for Mac][6].

## Configure the local instance

For testing purposes, it&#8217;s always helpful to set up the first instance locally, test it and perform all the necessary adjustments, and then [deploy it to the cloud][7].

Next, open **/vossibility-stack/collector/examples** and change the file extension to **.toml **&#8211; simply strip the **.example** suffix.

![Config Files](/images/postmedia/set-up-vissibility-track-github-contributions/Screenshot-2016-10-23-18.13.54.png)

Open **config.toml** and set a value for the **github\_api\_token** variable. You can get the token in [GitHub settings][8].

![Config Editing](/images/postmedia/set-up-vissibility-track-github-contributions/Screenshot-2016-10-23-18.16.20.png)

Next, make sure to add the repositories that you would like to track. That is done in the **[repositories]** node.

![Config Editing](/images/postmedia/set-up-vissibility-track-github-contributions/Screenshot-2016-10-23-18.21.17.png)

Save and close the file. Move the configuration files to **/vossibility/volumes/collector**. Navigate to the **Vossibility** folder in the Terminal.

![Terminal](/images/postmedia/set-up-vissibility-track-github-contributions/Screenshot-2016-10-23-18.24.00.png)

Make sure to also start the local docker machine. You can do so via **docker-machine start default**. Once ready, trigger **docker-compose build**.

![Terminal](/images/postmedia/set-up-vissibility-track-github-contributions/Screenshot-2016-10-23-18.27.20.png)

Once successful, trigger **docker-compose pull**. This will pull all required dependencies.

![Terminal](/images/postmedia/set-up-vissibility-track-github-contributions/Screenshot-2016-10-23-18.28.32.png)

This can take a couple of minutes depending on the quality of your internet connection and server latency.

Last but not least, trigger **docker-compose up**.

![Terminal](/images/postmedia/set-up-vissibility-track-github-contributions/Screenshot-2016-10-23-21.36.39.png)

Wait for the system to bootstrap, and then you will be ready to go, able to access Kibana (the visualization stack) at **http://localhost:5601**.

In future articles, I will outline the next steps that you can take to actually visualize the inbound repository contribution data.

## Important Note &#8211; Elastic Search

In case you are running this on a Mac (just like I did) and are [running into issues][9] with ElasticSearch not being able to start, try [using the native Mac Docker client][10] (at the time of writing this article it is in beta).

 [1]: https://docs.microsoft.com
 [2]: https://github.com/icecrime/vossibility-stack
 [3]: https://github.com/icecrime
 [4]: https://github.com/docker
 [5]: https://desktop.github.com/
 [6]: https://docs.docker.com/engine/installation/mac/
 [7]: https://azure.microsoft.com/en-us/
 [8]: https://github.com/settings/tokens
 [9]: https://github.com/boot2docker/boot2docker/issues/581
 [10]: https://docs.docker.com/docker-for-mac/