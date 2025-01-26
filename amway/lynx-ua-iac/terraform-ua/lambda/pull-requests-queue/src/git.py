import requests
import helpers

from github import Github, GithubException

# Const
APPROVED = "APPROVED"
CHANGES_REQUESTED = "CHANGES_REQUESTED"
QUEUE_LABEL = "add to queue"
QUEUE_LABEL_URGENT = "add to queue urgent"


class PullRequest(dict):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.__dict__ = self


class GitClient:
    def __init__(self, token):
        self.g = Github(token)

    # this method is used to get all open PR for config repo, we just
    # interested in pull requerst existance there
    def get_all_pull_requests(self, git_repo, *args):
        pull_requests = []
        # Faster then get all and sort
        list_of_prs = [git_repo.get_pulls(base=x) for x in args]
        for prs in list_of_prs:
            for pr in prs:
                pull_requests.append(pr)
        return pull_requests

    def get_brief_pull_requests(self, git_repo, *args, sort=True):
        pull_requests = []
        # Faster then get all and sort
        list_of_prs = [git_repo.get_pulls(base=x) for x in args]
        for prs in list_of_prs:
            for pr in prs:
                labels = {x.name: True for x in pr.labels}
                if labels.get(QUEUE_LABEL) or labels.get(QUEUE_LABEL_URGENT):
                    pull_requests.append(pr)

        return sorted(
            pull_requests,
            key=helpers.sort_pr_based_on_label) if sort else pull_requests

    @helpers.repeat(5)
    def get_detailed_pull_request(self, pull_num, git_repo):
        # get PRs list
        git_pull_request = git_repo.get_pull(pull_num)

        return generate_pr_obj(git_repo, git_pull_request)

    def delete_branch(self, git_pull_request, git_repo):
        ref = "heads/{h}".format(h=git_pull_request.head.ref)
        git_ref = git_repo.get_git_ref(ref)

        git_ref.delete()

    def get_git_repo(self, repo_name):
        return self.g.get_repo(repo_name)

    def get_user(self, login):
        user = self.g.get_user(login)
        return user.name if user.name else login

    def set_label(self, git_pull_request, label, override=True):
        if override:
            try:
                git_pull_request.remove_from_labels(label)
            except GithubException as err:
                if not err.status == 404:
                    raise err
        git_pull_request.add_to_labels(label)

    def reset_labels(self, git_pull_request):
        git_pull_request.delete_labels()

    def __get_single_pull_request(self, git_repo=None, num=0):
        pull_request = git_repo.get_pull(num)
        return pull_request


def generate_pr_obj(git_repo, pr):
    # i don't remeber why i needed separate obj for pr
    # but i felt like it was break through to solve some issue
    p = PullRequest(git_pull_request=pr,
                    number=pr.number,
                    mtime=pr.updated_at,
                    base=pr.base.ref,
                    url=pr.html_url,
                    href_url='<a href="{url}">{num}</a>'.format(url=pr.html_url, num=pr.number),
                    head=pr.head.ref,
                    approved=False,
                    mergeable_state=pr.mergeable_state)

    # https://developer.github.com/v3/git/#checking-mergeability-of-pull-requests
    # so raise error and just request for pr one more time via repeat decorator
    if pr.mergeable is None:
        raise RuntimeError(
            "Pull request mergeable state is None, must be bool")
    p.mergeable = pr.mergeable

    # Get labels in convinient store type
    p.labels = {x.name: True for x in pr.labels}

    # Get review state
    reviews = set([x.state for x in pr.get_reviews()])
    if APPROVED in reviews:
        p.approved = True

    # get Combined state and list of statuses
    commit = git_repo.get_commit(pr.head.sha)
    combined_status = commit.get_combined_status()

    p.combined_state = combined_status.state
    p.statuses = [
        s.description for s in combined_status.statuses if s.description
    ]

    p.login = pr.user.login

    return p
