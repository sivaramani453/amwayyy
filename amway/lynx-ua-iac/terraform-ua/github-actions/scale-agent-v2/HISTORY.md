# Development history

## Origin of the code

Most of the code was taken from already existing resources, like old scale agent, middleware etc. Some of the code is directly copied from official terraform examples.

Python code is basically old scaler, reworked for new approach, which made it much simpler and smaller.

## Dev steps

* Create runner image, making runner ephemeral and halt after job execution,
* Copypaste original code and rework main.py lambda handler, so it will create spot at each execution,
* Create APIGW and attach it to lambda
* Atatch APIGW to GithubActions webhook and test everything together
* Make lambda create spots ONLY on job queue webhook received, not job run or job success.
* Also make lambda create runners only when the job is labelled as self-hosted
* Refactor parameters passing, so everything will be tagged with job id, so cleanup will be easier
* Make cleanup code, so it will be possible to remove all leftovers after job
* Bind cleanup code with APIGW and complete step
* Protect APIGW/LAMBDA with Apikey or GitHub secret
* Handling situation when instances of a given kind are unavaliable (described in other section in readme)
* Writing simple Teams notificator
* Upgrading notificator so it can be easily extended and configured

* For UA split: throw away all unnessesary infra, like ApiGW, since lambda can be invoked by url
* For UA split: take Git org and Git repo from webhook payload so scaler can be shared between multiple repositories that builds on the same AWS account

## Problems experienced during development
* Concurency limited to 1 as I copypasted from old version.
* I experience problems while attempting to tag SpotRequest, so far I just log it and skip fixing
* When requesting a spot, I cannot configure request duration. All attempts lead to errors. I leave it commented out.
* GitHub is signing webhook payloads, instead of using API Key that would be handy for ApiGW service.