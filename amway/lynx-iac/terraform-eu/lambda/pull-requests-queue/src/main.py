import os
import functools

from pprint import pprint
from git import GitClient

import log
import helpers
from config import config
from dynamodb import DynamoTable
from dynamodbusers import DynamoTableUsers

from ssm import SSMParameterStore
from notificator import SkypeNotificator, TeamsNotificator
from handlers import Job, RelabelHandler, AddToQueueHandler, MergePullRequestHandler, MergePullRequestHandler
from distutils.util import strtobool

# Const
MERGE_LABEL = "merge it"
PR_FAILED_LABEL = "PR_FAILED"
PR_REJECTED_LABEL = "REJECTED"
BASE_BRANCH_LOCKED_LABEL = "BASE_BRANCH_IS_LOCKED"
HANDLERS = {
    "notify_and_relabel": RelabelHandler,
    "proceed_valid_pr": AddToQueueHandler,
    "proceed_failed_pr": MergePullRequestHandler,
    "proceed_merging_pr": MergePullRequestHandler
}

# Global vars
token = os.environ.get("GIT_TOKEN")


class Context:
    pass


def get_merging_pull_requests(prs):
    res = []
    for pr in prs:
        if pr.labels.get("merge it"):
            if pr.labels.get("q: add") or pr.labels.get(
                    "q: add top"):
                res.append(pr)
    return res


def get_not_mergeable_prs(prs):
    res = []
    for pr in prs:
        if not pr.mergeable:
            res.append(pr)
    return res

def get_rejected_prs(prs):
    res = []
    for pr in prs:
        if pr.rejected:
            res.append(pr)
    return res

def get_prs_with_combined_state(state, *prs):
    res = []
    for pr in prs:
        if pr.combined_state == state:
            res.append(pr)
    return res


def get_not_approved_prs(prs):
    res = []
    for pr in prs:
        if not pr.approved:
            res.append(pr)
    return res

def get_locked_base_branch_prs(prs, ctx):
    res = []
    for pr in prs:
        if strtobool(ctx.ssm.get_ssm_parameter("locked-" + ctx.env + "-" + pr.base)):
            res.append(pr) 
    return res    

# In order do decrease complexity to avoid tons of if/else
# all over the place  (becuse with different PRs different actions
# should be executed) PR and it's state/instrucrion will be returned
# and based on this instruction different pull request handler
# will be started (for merge, for update, for label etc)
def get_jobs_for_pulls(g, git_repo, ctx, *args):
    # create jobs datatype separated by branches
    jobs = {}
    for ref in args:
        jobs[ref] = {
            "primary": [],
            "secondary": [],
            "labeling": [],
            "enqueue": []
        }

    # get_brief_pull_requests will return sorted prs
    sorted_prs = g.get_brief_pull_requests(git_repo, *args)
    # Now it is time to get more detailed info about each PR
    # like reviews and combined statuses
    sorted_prs = list(
        map(functools.partial(g.get_detailed_pull_request, git_repo=git_repo),
            [pr.number for pr in sorted_prs]))

    # Here is chain of ordered checks for Pr condition
    # on each step pr is deleted from chain, so each pr
    # will hold only 1 failed state (locked base branch, not able to be merged, nor successfull checks...)
    locked_base_branch_prs = get_locked_base_branch_prs(sorted_prs, ctx)    
    for pr in locked_base_branch_prs:
        # Get him out of processing line so won't spend any resources 
        sorted_prs.remove(pr)
        
        # identify user to make msg more user friendly
        username = pr.login
        msg = "Base branch: {base} is locked. Please check your {url}".format(
            base=pr.base, url=pr.href_url)

        job = Job(pr=pr,
                  action="notify_and_relabel",
                  label=BASE_BRANCH_LOCKED_LABEL,
                  ghid=username,
                  msg=msg,
                  reason="pull request created to locked branch")
        jobs[pr.base]["labeling"].append(job)


    not_mergeable_prs = get_not_mergeable_prs(sorted_prs)
    for pr in not_mergeable_prs:
        # Get him out of processing line too
        sorted_prs.remove(pr)

        # identify user to make msg more user friendly
        username = pr.login
        msg = "{base}: Please fix conflicts in {url}".format(
            base=pr.base, url=pr.href_url)

        job = Job(pr=pr,
                  action="notify_and_relabel",
                  label=PR_FAILED_LABEL,
                  msg=msg,
                  ghid=username,
                  reason="pull request is not mergeable")
        jobs[pr.base]["labeling"].append(job)

    rejected_prs = get_rejected_prs(sorted_prs)
    for pr in rejected_prs:
        sorted_prs.remove(pr)

        username = pr.login
        msg = "{base}: PR was rejected due to changes requested in {url}".format(
            base=pr.base, url=pr.href_url)

        job = Job(pr=pr,
                  action="notify_and_relabel",
                  label=PR_REJECTED_LABEL,
                  ghid=username,
                  msg=msg,
                  reason="pull request was rejected due to changes requested")
        jobs[pr.base]["labeling"].append(job)

    failed_checks_prs = get_prs_with_combined_state("failure", *sorted_prs)
    for pr in failed_checks_prs:
        # Get him out of processing line too
        sorted_prs.remove(pr)

        # identify user to make msg more user friendly
        username = pr.login
        msg = "{base}: Please fix status checks in {url}".format(
            base=pr.base, url=pr.href_url)
        # So what's the deal with 2 jobs, optional jobs will contain
        # failed pr that will be procedd only if mandatory list is
        # empty, but part of work for this PR must be done, like
        # notify users and mark with apropriate label
        job = Job(pr=pr,
                  action="notify_and_relabel",
                  label=PR_FAILED_LABEL,
                  ghid=username,
                  msg=msg,
                  reason="pull request status checks are failed")
        jobs[pr.base]["labeling"].append(job)

        job_opt = Job(pr=pr, action="proceed_failed_pr")
        jobs[pr.base]["secondary"].append(job_opt)

    # So you may ask (i did) why do we need fail pull request and drop all labels
    # if it is mergeable and even status checks are fine. We need this
    # to remove such prs from queue to avoid waiting for review and bottleneck other PRs
    # so if somebody added q: add label one should ensure it is actually ready to be merged
    not_approved_prs = get_not_approved_prs(sorted_prs)
    for pr in not_approved_prs:
        # Get him out of processing line too
        sorted_prs.remove(pr)

        # identify user to maje msg more user friendly
        username = pr.login
        msg = "{base}: Please make sure {url} is approved".format(
            base=pr.base, url=pr.href_url)
        job = Job(pr=pr,
                  action="notify_and_relabel",
                  label=PR_FAILED_LABEL,
                  ghid=username, 
                  msg=msg,
                  reason="lack of reviews")
        jobs[pr.base]["labeling"].append(job)

    # Get pull requests with 'merge it' label
    # and if they are here so far they are approved and not failed
    merging_prs = get_merging_pull_requests(sorted_prs)
    for pr in merging_prs:
        # Get him out of processing line
        sorted_prs.remove(pr)

        job = Job(pr=pr, action="proceed_merging_pr")
        jobs[pr.base]["primary"].append(job)
        # We are interested only in 1 merging pr. Why...
        # Only 1 PR should contain merging label, because if we will have multiple of them the next case will happen
        # Let's say 10 oredered by update time  prs are in merging queue, so handler will be MergeHandlre, which
        # contains pressing Update branch button in github, by that action 5 new PR checks will spawn in aws or whatever
        # but the main thing is that update time will change so it goes to the end of line, and next script run next PR will be taken
        # and updated as well. So for the last pr in queue it will be updated 9 times which is useless and cost money for agents

    # for this stage only nice PRs could get, so they are ready to be
    # proceed. However we will take only 1 of them, first one since
    # order is matter
    for pr in sorted_prs:
        msg = "{url} will be added to merge queue.".format(url=pr.href_url)
        job = Job(pr=pr,
                  action="proceed_valid_pr",
                  reason="merge candidate",
                  msg=msg,
                  label=MERGE_LABEL)
        jobs[pr.base]["enqueue"].append(job)

    # Ok, jobs now may contain several PRs, valid and not, each will be
    # handled based on it's action attr
    return jobs


def main(context):
    context.logger.debug("Process started")
    g = GitClient(token=token)
    context.logger.debug("Git driver initialized")

    r = g.get_git_repo(context.config.repo[context.env].name)
    context.logger.debug("Initialized connection to git repo: {name}".format(
        name=config.repo[context.env].name))
    context.logger.debug(
        "Going to analyze all pull requests based on labels, reviews, status check results"
    )

    all_jobs = get_jobs_for_pulls(g, r, context, *config.repo[context.env].branches)

    # most important log output, a little bit overweighted though
    for ref, jobs in all_jobs.items():
        context.logger.info(
            "Found {primaries} pulls marked as primary ({primary_prs}), {secondaries} marked as failed pulls (combined_status = 'failure') ({secondaries_pr}), {labels} pulls to relabel ({label_prs}) and {candidates} to enqueue ({candidates_prs}) in {branch}"
            .format(primaries=len(jobs["primary"]),
                    secondaries=len(jobs["secondary"]),
                    labels=len(jobs["labeling"]),
                    candidates=len(jobs["enqueue"]),
                    branch=ref,
                    primary_prs=", ".join(
                        [str(x.pr.number) for x in jobs["primary"]]),
                    secondaries_pr=", ".join(
                        [str(x.pr.number) for x in jobs["secondary"]]),
                    label_prs=", ".join(
                        [str(x.pr.number) for x in jobs["labeling"]]),
                    candidates_prs=", ".join(
                        [str(x.pr.number) for x in jobs["enqueue"]])))

    for ref, jobs in all_jobs.items():
        # We will start with labeling stuff
        for job in jobs["labeling"]:
            # debug purpuse, delete/comment after
            context.logger.debug(helpers.get_debug_string(job.pr))

            # i've added reason just to increase log clarity why exactly we will drop labels and fail PR
            reason = job.reason
            context.logger.info(
                "Going to relabel pull request {url} and with new one: {label}. Reason: {reason}"
                .format(url=job.pr.url, label=job.label, reason=job.reason))
            HANDLERS[job.action](g, r, job).Handle(context)

        # Now primary jobs, not just jobs, but only the first one in every branch
        if len(jobs["primary"]) > 0:
            job = jobs["primary"][0]
            # debug purpuse, delete/comment after
            context.logger.debug(helpers.get_debug_string(job.pr))

            context.logger.info(
                "Going to procced with {handler} for {url}".format(
                    url=job.pr.url, handler=job.action))
            HANDLERS[job.action](g, r, job).Handle(context)

            # As we started with primary task
            # we will ignore PRs in secondary and just continue with other branches
            continue

        # If there were no any primary tasks we will proceed with merge candidate now
        if len(jobs["enqueue"]) > 0:
            job = jobs["enqueue"][0]
            context.logger.debug(helpers.get_debug_string(job.pr))
            # Additional info for skype notifications
            if len(jobs["enqueue"]) > 1:
                pulls_in_queue = ", ".join(
                    [j.pr.href_url for j in jobs["enqueue"][1:]])
                job.msg = "{msg} Still in queue in {ref}: {n} (in order to proceed: {pull_nums})".format(
                    msg=job.msg,
                    ref=ref,
                    n=len(jobs["enqueue"]) - 1,
                    pull_nums=pulls_in_queue)
            else:
                job.msg = "{msg} Still in queue in {ref}: 0".format(
                    msg=job.msg, ref=ref)
            context.logger.info(
                "Going to procced with {handler} for {url}".format(
                    url=job.pr.url, handler=job.action))

            HANDLERS[job.action](g, r, job).Handle(context)
            continue

        # If there were no any primary or merge candidates tasks we will procced with failed jobs
        if len(jobs["secondary"]) > 0:
            job = jobs["secondary"][0]
            # debug purpuse, delete/comment after
            context.logger.debug(helpers.get_debug_string(job.pr))
            context.logger.info(
                "There were no primary pull requets so failed one was taken. {url}"
                .format(url=job.pr.url))
            HANDLERS[job.action](g, r, job).Handle(context)


def lambda_handler(event, context):
    logger = log.get_global_logger("main", debug=True)

    ctx = Context()
    ctx.aws_context = context
    ctx.logger = logger
    ctx.config = config
    ctx.env = os.environ.get("REGION", "eu")
    # when asked, change Skype driver to Teams or write new one
    # rest part will stay untouched (context.notificator.send_message("message to send"))
    if ctx.env == "eu":
        dynamoUsers = DynamoTableUsers(config.dynamodbusers.tablename, config.dynamodbusers.region)
        ctx.notificator = [
            TeamsNotificator(to=config.teams.chan["eu"],
                             secret=config.teams.secret,
                             url=config.teams.url,
                             dynamoTableUsers = dynamoUsers)
        ]
    elif ctx.env == "ru":
        ctx.notificator = [
            SkypeNotificator(to=config.skype.chan["ru"],
                             secret=config.skype.secret,
                             url=config.skype.url)
        ]
    else:
        ctx.notificator = [StubNotificator()]

    dynamodb = DynamoTable(config.dynamo.tablename, config.dynamo.region)
    ctx.dynamodb = dynamodb
    ssm = SSMParameterStore(config.ssmparameter.region)
    ctx.ssm = ssm

    main(ctx)


if __name__ == "__main__":
    lambda_handler("", "")
