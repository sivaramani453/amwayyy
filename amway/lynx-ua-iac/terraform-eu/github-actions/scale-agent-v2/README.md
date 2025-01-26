# GitHub Actions scale agent v2

## How does it work?
 The backbone of the whole solution is simply tight connecting GitHub webhooks with lambdas that are scaling resources and do other things, with ephemeral runners (executes one job and quits) implemented as spots (terminates after doing their job, nothing required for it to happen, but usual shutdown -h now)

 * Lambdas that does one thing well. When using webhooks, we can specify which lambda will handle it. As a result, we get smaller lambdas doing less, which are easier for maintenance

 * Rely on events rather than crons. We save a lots of API calls.

 * Rely on AWS mechanisms to implement our logic. It simplifies the code and is less error-prone than doing logic on our own.

 * Use spots. They are invented just to be ephemeral workers on cheap, so let's use it for this purpose.

 * When spot instance of a given type is unavailable, use another type, just one-level better, as long as we have anything to choose from.

 ## Resources to look at

 https://github.blog/changelog/2021-09-20-github-actions-ephemeral-self-hosted-runners-new-webhooks-for-auto-scaling/

 https://docs.github.com/en/developers/webhooks-and-events/webhooks/webhook-events-and-payloads#workflow_job

 ## How to redeploy?

 You may want to have envvar named LAMBDA_FUNC_NAME holding name of your lambda function you'd like to update. S3 bucket names and other stuff is something which is not changing when depoying diffrent scaleagents, but unfortunatelly lambda functions are diffrent for every scaler. Storing it in an envvar will speed up your process, as it will be used as default for prompt values and you will not need to specify it everytime you make an deployment.

 * Go to the src 
 * make build <-- this installs all nessesary dependencies
 * make upload <-- this makes zip archive and uploads everything to S3 bucket
 * make deploy <-- this replaces lambda body with new content, uploaded to S3 in previous step

## Capacity exceeded failover

In case machine of configured type is unavailable in AWS when the job is queued and we try to launch spot runner, we try to switch to corresponding AMD machine, then we switch to higher Intel instance, then AMD, then higher Intel, then AMD, and so on, as long as we have anything to switch to.

## Notifications

You can set up notifications so far by Teams chanel, by specifying Teams webhooks urls in an env variable, one url in a line. The code is organized in a way that allows to extend noticiations easily just by making class for every channel (like Teams, Skype, Email, SMS etc), and then building notification structure in DI.

## DI

I decided to make simple DI container that is being passed from main handler down to every class. The container handles lazy dependencies creation, and should be the main place where objects are being created.

## Naming runners

Runners shoud be named just as their AWS instance id, so later we can easily detect which AWS machine picked up which job.

## Cleaning up

The runner shall shut itself down right when the job processing is over, and we achieve this by making runner ephemeral (Unix process quits when the job processing is over), and executing shutdown -h now as a next command in a script. Therefore we don't need to delete/clean machine, and we only need to clean up other things, like SSM parameters created for that machine. And that's preciselly what we do.

## GOTCHAS

There's only one gotcha/weakness I identified so far: when error occurs, no reattempt is taken, as everything is triggered only once via webhook. Options for solving this may be storing requests in a AWS SimpleQueue, and then use our code as a runner... But so far, we don't do that. Instead, I figured out that we need to be informed ASAP when anything fails, so we can take manual actions to fix what's broken.

## Retry worker spawning

* First of all, check type of the machine required for the job
* On GitHub repo webpage, go to Settings - Webhooks, search for a scaler webhook, and open it.
* On Recent deliveries tab, find webhook for 'queued' action and for a required machine type, then simply hit Resend button

## Use old runners (non-ephemeral)

In completed.py file there's a code that is commented out. We may simple reenable it to terminate workers when their job is over, however be aware that doing this in busy environment may occasionally lead to jobs already being picked up by the agent that is being killed, and therefore cancelled.