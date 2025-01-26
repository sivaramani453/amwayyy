from git import GitClient
from pprint import pprint
from config import config
from dynamodb import Cache
from aws import AWSClient
from log import get_global_logger
from helpers import *
from notificator import SkypeNotificator


class Context:
    pass


def get_avail_runers(ctx):
    runners = ctx.g.get_runners("online")
    avail_runners = [r for r in runners if not r.busy]
    return avail_runners


def get_proper_runner(instance_type, avail_runners):
    for i, runner in enumerate(avail_runners):
        runner_labels = [x["name"] for x in runner.labels]
        if instance_type in runner_labels:
            return i
    return -1


def get_jobs_in_queue(ctx):
    runs = ctx.g.get_wf_runs()
    q_runs = [x for x in runs if x.status in ["queued", "in_progress"]]

    q_jobs = []
    for r in q_runs:
        q_jobs.extend(
            [job for job in ctx.g.get_wf_jobs(r.id) if job.status == "queued"])
    return q_jobs


def delete_instance_in_ec2(ctx, name):
    try:
        ctx.a.terminate_instances([name])
    except Exception as err:
        msg = "Could not delete instance {0}: {1}".format(name, err)
        ctx.l.error(msg)
        ctx.n.send_message(msg)


def delete_instance_in_ssm(ctx, name):
    try:
        ctx.a.delete_ssm_params(name)
    except Exception as err:
        msg = "Could not delete parameters for instance {0}: {1}".format(
            name, err)
        ctx.l.error(msg)
        ctx.n.send_message(msg)


def delete_instance_in_cache(ctx, name):
    try:
        ctx.c.remove_item("created", name)
    except Exception as err:
        msg = "Could not delete instace {0} from 'created' cache object: {1}".format(
            name, err)
        ctx.l.error(msg)
        ctx.n.send_message(msg)


def delete_instance_in_github(ctx, id):
    try:
        ctx.g.delete_runner(id)
    except Exception as err:
        ctx.l.error(err)
        ctx.n.send_message(err)
        return err
    return None


def delete_unused_runners(ctx, avail_runners):
    if not avail_runners:
        ctx.l.info("Nothing to delete, since there is no avail runners")

    for r in avail_runners:
        # delete runners since task list is empty
        # also delete aws instances and params from ssm
        ctx.l.info("Deleting runner {0} in GitHub".format(r.name))
        err = delete_instance_in_github(ctx, r.id)
        if err: continue

        created_instances = ctx.c.get_item("created", [])
        if r.name in created_instances:
            # Delete instance in aws
            ctx.l.info("Deleting instance {0} in ec2".format(r.name))
            delete_instance_in_ec2(ctx, r.name)

            # Delete instance from list of created in cache
            ctx.l.info("Deleting instance {0} in  cache".format(r.name))
            delete_instance_in_cache(ctx, r.name)

            # Delete params from ssm
            ctx.l.info("Deleting instance {0} in ssm ".format(r.name))
            delete_instance_in_ssm(ctx, r.name)

        else:
            ctx.l.warning(
                "Runner {0} found in GitHub however it was not found in list of spawned instances. Instance wont be deleted"
                .format(r.name))
    # So no tasks in queue, we deleted all active runners,
    # we can truncate all fulfilled jobs to allow rerun
    ctx.c.set_item("fulfilled", [])


def create_new_runners(ctx, avail_runners, jobs):
    # fulfilled ids is the job ids for which runners have been already started
    fulfilled_ids = ctx.c.get_item("fulfilled", [])
    in_queue_ids = [j.id for j in jobs]

    unprocessed_ids = list(set(in_queue_ids) - set(fulfilled_ids))
    all_ids = sorted(in_queue_ids + fulfilled_ids)
    ctx.l.info(
        "Found {0} unprocessed jobs, {0} instances will be lauched".format(
            len(unprocessed_ids)))
    # should be refactored in future
    in_queue_names = [j.name for j in jobs if j.id in unprocessed_ids]
    in_queue_types = map(get_type_by_name, in_queue_names)
    #
    if not unprocessed_ids:
        # we already spawned instances for all
        return None
    try:
        download_url = ctx.g.get_runner_package_url()
        ctx.l.debug("Found runner package url: {0}".format(download_url))
        userdata_vals = {
            "runner_user": config.runner.user,
            "runner_group": config.runner.group,
            "runner_workdir": config.runner.workdir,
            "download_url": download_url
        }
    except Exception as err:
        msg = "Could not get github runner download url: {0}".format(err)
        ctx.l.critical(msg)
        ctx.n.send_message(msg)
        return
    instance_ids, instance_ips = ([], [])
    try:
        for instance_type in in_queue_types:
            if not instance_type:
                instance_type = config.aws.instance_type
            instances = ctx.a.create_instances(
                count=1,
                name="ga-runner-{0}".format(config.git.repo),
                subnet=config.aws.subnet,
                ami=config.aws.ami,
                userdata_vals=userdata_vals,
                disk_size=config.aws.disk_size,
                type=instance_type,
                kp=config.aws.kp,
                sg=config.aws.sg,
                iam_profile=config.aws.iam_profile)
            instance_ids.extend([i.id for i in instances])
            instance_ips.extend([i.ip for i in instances])
    except Exception as err:
        msg = "Could not start instance: {0}".format(err)
        ctx.l.critical(msg)
        ctx.n.send_message(msg)
        return

    ctx.l.info("{0} launched ({1})".format(", ".join(instance_ids),
                                           ", ".join(instance_ips)))
    ctx.c.set_item("fulfilled", all_ids)
    ctx.c.append_item("created", *instance_ids)
    ctx.c.save()
    ctx.l.debug("Instance ids and job ids were saved in cache")

    full_repo_name = "{0}/{1}".format(config.git.org, config.git.repo)
    for id in instance_ids:
        try:
            join_token = ctx.g.get_runner_join_token()
        except Exception as err:
            ctx.l.error(err)
            ctx.n.send_message(err)
            continue
        ctx.l.info("Join token were obtained in github: {0}***{1}".format(
            join_token[:2], join_token[-2:]))
        # put token and repo to ssm param store
        try:
            ctx.a.put_ssm_params(id, full_repo_name, join_token)
            ctx.l.info(
                "Repo and token were put in smm param store for instance {0}".
                format(id))
        except Exception as err:
            msg = "Could not put required params for instance: {0}".format(id)
            ctx.l.error(msg)
            ctx.n.send_message(msg)


def lambda_handler(event, context):
    ctx = Context()
    # pass aws context
    ctx.lambda_context = context
    # custom objects
    ctx.l = get_global_logger("main", debug=True)
    ctx.c = Cache(config.dynamodb.tablename, config.dynamodb.region)
    ctx.a = AWSClient(config.aws.region)
    try:
        ctx.g = GitClient(config.git.org, config.git.repo, config.git.token)
    except Exception as err:
        ctx.l.critical("Could not initialize git obj: {0}".format(err))
        return
    ctx.n = SkypeNotificator(url=config.skype.url,
                             dest=config.skype.chan,
                             secret=config.skype.secret)

    ctx.l.debug("Run scale agent, git, aws, cache obj initialized")
    # runners
    try:
        avail_runners = get_avail_runers(ctx)
    except Exception as err:
        ctx.log.critical(err)
        ctx.n.send_message(err)
        return

    ctx.l.info("Received avail runners count for {0}/{1}. Number: {2}".format(
        config.git.org, config.git.repo, len(avail_runners)))

    # jobs
    try:
        jobs = get_jobs_in_queue(ctx)
    except Exception as err:
        ctx.log.critical(err)
        ctx.n.send_message(err)
        return

    ctx.l.info("Received {} jobs in queue".format(len(jobs)))
    if jobs:
        ctx.l.debug("Jobs ids: {0}".format(", ".join([str(j.id)
                                                      for j in jobs])))

    # if no new jobs, delete extra resources
    if len(jobs) == 0:
        ctx.l.info(
            "Going to delete instances in aws since there is no jobs in queue")
        delete_unused_runners(ctx, avail_runners)

    # so we will iterate over jobs and check if there are runner with
    # appropriate type available
    jobs_to_proceed = []
    for job in jobs:
        instance_type = get_type_by_name(job.name)
        ctx.l.debug("Job {0} required {1} instance type explicitly".format(
            job.name, instance_type))
        if not instance_type:
            instance_type = config.aws.instance_type
            ctx.l.debug("Instype type for {0} for rewritten to {1}".format(
                job.name, instance_type))

        proper_runner = get_proper_runner(instance_type, avail_runners)
        if proper_runner >= 0:
            ctx.l.debug(
                "Runner capable to exec {0} was found ({1}). Job will be skipped"
                .format(job.name, avail_runners[proper_runner].name))
            avail_runners.pop(proper_runner)
            continue

        ctx.l.debug("Job {0} requires additional instance".format(job.name))
        jobs_to_proceed.append(job)

    if jobs_to_proceed:
        ctx.l.info(
            "Insufficient number of runners for jobs in queue, going to spawn instances"
        )
        create_new_runners(ctx, avail_runners, jobs_to_proceed)
    else:
        ctx.l.info(
            "There are sufficient runners for current amount of queued jobs, do nothing"
        )


if __name__ == "__main__":
    lambda_handler(None, None)
