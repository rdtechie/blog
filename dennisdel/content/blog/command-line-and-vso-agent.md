---
title: Command line and vso-agent
type: blog
date: 2015-11-25T06:23:54+00:00
---

A while ago Microsoft released this wonderful thing called the VSO agent &#8211; a cross-platform build agent that you can set up on MacOS X and/or Linux and hook it directly to a VSO or TFS instance to handle automated builds with a lot of customization options. You can get it <a href="https://github.com/Microsoft/vso-agent" target="_blank">here</a>.

So here comes the challenge &#8211; more often than not, the build agent should be automatically set up, but the documentation mentions that the instance details, such as the service URL, username and password are manually entered. Not exactly what you want to do in an automated scenario. The good news is that there is a (not so) secret option to use command line parameters for the vso-agent:

```bash
node agent/vsoagent.js --u YOUR_USERNAME --p VSO_ONE_USE_TOKEN --s https://VSO_URL.visualstudio.com --a AGENT_NAME --l AGENT_POOL_CAN_BE_DEFAULT
```

Voila! All of a sudden, you can include this in your deployment scripts.