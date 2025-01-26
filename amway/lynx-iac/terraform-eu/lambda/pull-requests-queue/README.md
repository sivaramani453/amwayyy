### Lambda func for github pull request queue
### Workspaces
2 workspaces available currently:
  * eu
  * ru
Please note that few vars are bound to ${terraform.workspace}
#### Install src
  * Go to src dir
  * make  // install deps and make zip archieve artifact
  * make install // upload zip archieve to s3 bucket
  * make deploy // update lambda function code
  * make clean // delete all deps in current directory
  * make help // help msg


### Manager workflow
> Queue manager code contains a lot of useful comments, give it a shot and explore it

#### handlers.py
In order to decrease complexity all actual work with pulls organized by Handlers. Handler is an interfcae that must implement Handle and send_message methods. It accepts 3 predefined args

#### main.py
Thos is an entrypoint. Every call of lambda func detects various case pulls and activate appropriate Handler's Handle method.

#### Workflow
  * Get all pulls with 'queue related' label. Sort it by mtime
  * Get all info about each pr from prev step
  * Exclude pulls with not mergeable state (conflicts)
  * Exclude pulls with failed status checks 
  * Exclude pulls without approve 
  * Get pulls with 'merge it' label. If exists, take the very first one and skip next step
  * If no 'merge it' pulls were found, the very first pr is taken to enqueue it (label it with 'merge it' label)
> To be more specific, all prev steps generate so called job lists (list of failed pulls, list of pulls to enqueue and so on) on then handlers are called to each pull in list or just to the first.
  * Call handlers to all pulls (notify users about failure, relabel pull with 'failed' label and so on)
  * Once we have valid candidate with 'merge it' label we switch to him
      * Update branch (merge base in ref)
        * if successful, this means that git middleware will spawn special job that will run all status check jobs. We will just wait until jobs are done
        * If not, just go on, this means branch is up to date
      * Try to update branch in config repo
      * Check if pull request might be merged
        * If yes, try to merge pulls in config and main repos
        * If not, check why
          * If we just wait for status checks to finish then ok, wait
          * If pull request in queue for too long or not all status checks are in progress - label it with restarted label

### Tips and Tricks
  * Turning off and on in this case is labeling pull request with 'RESTARTED' label. It must be done by Hermes Konrad service user only.
  * Check log files in kibana and then in aws cloudwatch bucket. Cloudwatch bucket may contain python exceptions.
