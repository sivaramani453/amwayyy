import abc
import helpers
import github
from git import GitClient
from github.GithubException import UnknownObjectException
from datetime import datetime, timedelta

# Const
MERGE_LABEL = "merge it"
SQUASH_LABEL = "squash before merge"
RESTARTED_LABEL = "RESTARTED"
DO_NOT_DELETE_LABEL = "do not delete"


class Job(dict):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.__dict__ = self


class Handler(abc.ABC):
    def __init__(self, *args):
        if len(args) != 3:
            raise TypeError(
                "Handler interface must be initialized with 3 args: git.Gitclient, github.Repository.Repository, Job"
            )
        if not isinstance(args[0], GitClient):
            raise TypeError("First argument must be GitClient")
        if not isinstance(args[1], github.Repository.Repository):
            raise TypeError(
                "Second argument must be github.Repository.Repository object")
        if not isinstance(args[2], Job):
            raise TypeError("Last argument must be Hob object")
        self.g, self.r, self.j = args

    @abc.abstractmethod
    def send_message(self):
        pass

    @abc.abstractmethod
    def Handle(self):
        pass


class RelabelHandler(Handler):
    def send_message(self, msg, ctx):
        for n in ctx.notificator:
            n.send_message(msg)

    def Handle(self, ctx):
        # delete all labels from pr
        ctx.logger.info("Deleting all labels from pull request {url}".format(
            url=self.j.pr.url))
        delete_labels_from_pull_request(self.g, self.j.pr.git_pull_request)

        # Set label from job
        ctx.logger.info(
            "Re-seting label {label} for  pull request {url}".format(
                url=self.j.pr.url, label=self.j.label))
        label_pull_request(self.g, self.j.pr.git_pull_request, self.j.label)

        #notify_users(chat, j.msg)
        ctx.logger.info("Sending: <{msg}> for pull request {url}".format(
            url=self.j.pr.url, msg=self.j.msg))
        self.send_message(self.j.msg, ctx)


class AddToQueueHandler(Handler):
    def send_message(self, msg, ctx):
        for n in ctx.notificator:
            n.send_message(msg)

    def Handle(self, ctx):
        ctx.logger.info(
            "Re-seting label {label} for  pull request {url}".format(
                url=self.j.pr.url, label=MERGE_LABEL))
        label_pull_request(self.g, self.j.pr.git_pull_request, MERGE_LABEL)
        # Send message that PR will be added to merge queue
        self.send_message(self.j.msg, ctx)


class MergePullRequestHandler(Handler):
    # will be used later
    log = None
    pr_url = ""
    pr_num = 0
    config_repo = None
    config_pr = None

    def __init__(self, *args):
        super().__init__(*args)
        # simplify access to some vars
        self.pr_num = self.j.pr.number
        self.pr_url = self.j.pr.href_url

    def send_message(self, msg, ctx):
        for n in ctx.notificator:
            n.send_message(msg)

    def __update_main_branch(self, ctx):
        return update_feature_branch(self.r, self.j.pr)

    def __update_config_branch(self, ctx):
        env = ctx.env
        repo = ctx.config.repo[env]
        repo_name = repo.config_name

        self.config_repo = self.g.get_git_repo(repo_name)
        self.config_pr, error = self.__get_config_pull_request(ctx)

        if error:
            return False, error

        if not self.config_pr:
            return False, False

        if not self.config_pr.mergeable:
            return False, "You have conflicts in config repo"

        return update_feature_branch(self.config_repo, self.config_pr), False

    def __handle_failed_pr(self, msg, ctx):
        self.log.info("pr {num} will be unlabeled".format(num=self.pr_num))
        delete_labels_from_pull_request(self.g, self.j.pr.git_pull_request)
        self.send_message(msg, ctx)

    def __handle_hung_pr(self, ctx, force=False):
        if self.j.pr.labels.get(RESTARTED_LABEL) and not force:
            self.log.info("pr {num} already restarted".format(num=self.pr_num))
            return
        self.log.info("pr {num} will be restarted".format(num=self.pr_num))
        label_pull_request(self.g, self.j.pr.git_pull_request, RESTARTED_LABEL)
        self.send_message(
            "pull request {url} was restarted".format(url=self.pr_url), ctx)

    def __delete_merged_branches(self, ctx):
        if self.j.pr.labels.get(DO_NOT_DELETE_LABEL):
            self.log.info("DND flag was found, branch wont be deleted")
            return

        for repo in [self.r, self.config_repo]:
            try:
                self.g.delete_branch(self.j.pr.git_pull_request, repo)
                self.log.info("pr {num} branch in {repo} deleted".format(
                    num=self.pr_num, repo=repo.name))
            except Exception as err:
                self.log.warning(
                    "pr {num} branch in {repo} was not deleted: {err}".format(
                        num=self.pr_num, repo=repo.name, err=err))

    def __handle_in_progress_pr(self, ctx):
        env = ctx.env
        repo = ctx.config.repo[env]
        required_status_count = repo.statuses

        # check when PR was last updated
        delta = datetime.now() - self.j.pr.mtime
        status_list = self.j.pr.statuses

        if len(status_list) < required_status_count:
            # git -> middleware error
            # wait some time (restated label will be set 1 time
            # if aws apigw still broken this is pointless since
            # middleware won't be triggered by it)
            self.log.debug(
                "pr {num} does not have enogh statues: {n}/{t}".format(
                    num=self.pr_num,
                    n=len(status_list),
                    t=required_status_count))
            if delta.seconds > 1200:
                msg = "pr {url} does not contain enough statuses for 20 mins".format(
                    url=self.pr_url)
                self.send_message(msg, ctx)
                self.__handle_hung_pr(ctx)
                # no return here to still move pr out if it is in queue > 2.5h

        if delta.seconds < 9000:
            return

        item = ctx.dynamodb.get_item(self.pr_num, ctx.env)
        if not item.get("Item", {}):
            msg = "pull request {url} is in queue more then 2.5h".format(
                url=self.pr_url)
            self.send_message(msg, ctx)
            ctx.dynamodb.create_item(self.pr_num, ctx.env)
            self.__handle_hung_pr(ctx, force=True)

    def __merge_main_pr(self, ctx):
        msg, ok = merge_pr(self.j.pr)
        if not ok:
            return msg
        return ""

    def __merge_config_pr(self, ctx):
        if not self.config_pr:
            return ""

        if not self.config_pr.approved:
            return "Config pr is not approved"

        if self.config_pr.mergeable_state not in [
                "clean", "unstable", "has_hooks"
        ]:
            return "Config pr in unmergeable state"

        msg, ok = merge_pr(self.config_pr)
        if not ok:
            return msg

        return ""

    def __merge_branches(self, ctx):
        error = self.__merge_config_pr(ctx)
        if error:
            return error, False

        error = self.__merge_main_pr(ctx)
        if error:
            return error, False

        login = self.j.pr.login
        username = self.g.get_user(login)
        msg = "{base}: {user}, pull request {url} was merged".format(
            base=self.j.pr.base, user=username, url=self.pr_url)

        return msg, True

    def __find_config_pr(self, base_ref, head_ref, ctx):
        env = ctx.env
        repo = ctx.config.repo[ctx.env]
        branches = repo.branches

        prs = self.g.get_all_pull_requests(self.config_repo, *branches)

        for pr in prs:
            if pr.head.ref == head_ref and pr.base.ref == base_ref:
                return self.g.get_detailed_pull_request(
                    pr.number, self.config_repo)
        return None

    def __get_config_pull_request(self, ctx):
        head_ref = self.j.pr.head
        base_ref = self.j.pr.base
        ahead_by = 0

        try:
            comparsion = self.config_repo.compare(base_ref, head_ref)
            ahead_by = comparsion.ahead_by
        except UnknownObjectException:
            pass

        if ahead_by == 0:
            return False, False

        pr = self.__find_config_pr(base_ref, head_ref, ctx)
        if not pr:
            return pr, "Config pr not found but branch is ahead"

        return pr, False

    def Handle(self, ctx):
        self.log = ctx.logger

        updated = self.__update_main_branch(ctx)
        if updated:
            self.log.info(
                "pr {num}: branch was updated".format(num=self.pr_num))
            return

        updated, error = self.__update_config_branch(ctx)
        if error:
            error = "error with pr {url}: {err}".format(url=self.pr_url,
                                                        err=error)
            self.log.error(error)
            self.__handle_failed_pr(error, ctx)
            return

        if updated:
            self.log.info(
                "pr {num}: cfg branch was updated".format(num=self.pr_num))
            return
        # all branches are up to date

        pr_state = self.j.pr.mergeable_state
        if pr_state in ["clean", "unstable"]:
            self.log.info(
                "pr {num} going to be merged".format(num=self.pr_num))
            msg, ok = self.__merge_branches(ctx)
            if not ok:
                error = "could not merge pr {url}: {msg}".format(
                    url=self.pr_url, msg=msg)
                self.log.error(error)
                self.__handle_failed_pr(error, ctx)
                return

            # all good
            self.send_message(msg, ctx)
            self.__delete_merged_branches(ctx)

            return

        status_list = self.j.pr.statuses
        if "disabled" in status_list and "in progress" not in status_list:
            self.__handle_hung_pr(ctx)
            return

        self.log.info(
            "pr {num} is awaiting for checks".format(num=self.pr_num))
        self.__handle_in_progress_pr(ctx)
        return


def label_pull_request(g, pr, label):
    g.set_label(pr, label)


def delete_labels_from_pull_request(g, pr):
    g.reset_labels(pr)


def update_feature_branch(r, pr):
    # Call update branch button in git ui
    base = pr.base
    head = pr.head
    # merge dest branch to feature branch
    commit = r.merge(head, base)
    return commit


def merge_pr(pr):
    msg, ok = "", False
    merge_method = "squash" if pr.labels.get(SQUASH_LABEL) else "merge"
    try:
        pr_merge_status = pr.git_pull_request.merge(
            commit_message="Merged by Bender",
            commit_title="Merge pull request #{num}, title: #{title}".format(num=pr.number, title=pr.git_pull_request.title),
            merge_method=merge_method,
            sha=pr.git_pull_request.head.sha)

        if pr_merge_status.merged:
            msg, ok = "Main PR merged", True
        else:
            msg, ok = pr_merge_status.message, False
    except Exception as err:
        msg, ok = err.__str__(), False
    return msg, ok
