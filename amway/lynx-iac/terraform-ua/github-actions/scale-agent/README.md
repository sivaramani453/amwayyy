#### Scale agent
Current scale agent solution based on terraform warkspaces.
Each workspace responsible for 1 repo. Current ws list:
  * default - ws AmwayACS/actions repo. This ws used as default values for the rest and tests
  * auto - AmwayACS/AmwayAutoQA. Autotests repo
  * iac - AmwayACS/lynx-iac. Current repo
  * lynx - AmwayACS/lynx. This ws will be used to create pull request agents scale agent
