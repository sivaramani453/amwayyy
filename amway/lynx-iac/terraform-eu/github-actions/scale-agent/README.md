#### Scale agent
Current scale agent solution based on terraform workspaces.
Each workspace responsible for 1 repo. Current ws list:
  * default - ws AmwayACS/actions repo. This ws used as default values for the rest and tests
  * auto - AmwayACS/AmwayAutoQA. Autotests repo
  * iac - AmwayACS/lynx-iac. Current repo
  * lynx - AmwayACS/lynx. This ws will be used to create pull request agents scale agent

##### Deployment process
Deployment of scale agents contain two phases:
* compress and upload everything needed to "stage" S3 bucket,
* update lambda with code from S3 bucket

By doing so, we may quickly update multiple agents, while updating the code only once.

Therefore the whole process takes two commands to execute:
* make && make install (takes S3 bucket name, default value is usually OK)
* make deploy (takes S3 bucket name from previous step, and a name of the lambda we want to update)