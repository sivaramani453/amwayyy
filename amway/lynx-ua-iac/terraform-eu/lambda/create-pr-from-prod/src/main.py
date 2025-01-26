import boto3
from github import Github
from datetime import datetime
from config import Config
from teams import send_teams_message


def lambda_handler(event, context):
    # get config
    cfg = Config()

    # parameter store
    ssm = boto3.client('ssm')

    # get old lynx sha
    parameter_lynx_sha = ssm.get_parameter(Name='/' + cfg.parameter_lynx,
                                           WithDecryption=False)
    old_lynx_sha = parameter_lynx_sha['Parameter']['Value']

    # get old lynx config sha
    parameter_lynx_conf_sha = ssm.get_parameter(Name='/' +
                                                cfg.parameter_lynx_conf,
                                                WithDecryption=False)
    old_lynx_conf_sha = parameter_lynx_conf_sha['Parameter']['Value']

    # debug info
    print("Old lynx sha: {lynx}, old lynx config sha: {lynx_config}".format(
        lynx=old_lynx_sha, lynx_config=old_lynx_conf_sha))

    # Github connect
    git = Github(cfg.github_api_token)

    # get sha for lynx repo
    repository = git.get_repo(cfg.org + '/' + cfg.code_repo)
    ref_branch = repository.get_branch(cfg.ref)
    new_lynx_sha = ref_branch._commit.value.commit.sha

    repository = git.get_repo(cfg.org + '/' + cfg.config_repo)
    ref_branch = repository.get_branch(cfg.ref)
    new_lynx_conf_sha = ref_branch._commit.value.commit.sha

    print("New lynx sha: {lynx}, new lynx config sha: {lynx_config}".format(
        lynx=new_lynx_sha, lynx_config=new_lynx_conf_sha))

    if (old_lynx_sha == new_lynx_sha) or (
            old_lynx_conf_sha == new_lynx_conf_sha):
        print(
            "No changes in {ref} branches in {repo} and {conf_repo} repositories since last check"
            .format(ref=cfg.ref, repo=cfg.code_repo,
                    conf_repo=cfg.config_repo))
        return

    now = datetime.now()
    date = now.strftime('%d-%m-%Y_%H-%M-%S')

    # Send message to teams
    init_msg = '(star) Prod branch is updated, please merge following PRs to your branches:'
    send_teams_message(cfg.teams_chan, init_msg)

    # Some serious shit =)
    branches_list = cfg.branches.split(",")
    for base in branches_list:
        print("Checking branch: ", base)

        for repo in [cfg.code_repo, cfg.config_repo]:
            repository = git.get_repo(cfg.org + '/' + repo)
            ref_branch = repository.get_branch(cfg.ref)
            lastCommit = ref_branch._commit.value.commit
            midBranchName = 'merge-' + cfg.ref + '-to-' + base + '-' + date
            print('Creating mid branch {} in {}'.format(midBranchName, repo))
            try:
                midBranch = repository.create_git_ref(ref='refs/heads/' +
                                                      midBranchName,
                                                      sha=lastCommit.sha)
                print(midBranch.ref)
            except:
                msg = base + ' (' + repo + ') An ERROR happend while ' + midBranchName + ' branch creation'
                send_teams_message(cfg.teams_chan, msg)

            try:
                pr = repository.create_pull('Merge prod -> ' + base,
                                            'please merge', base,
                                            midBranchName)
                msg = base + ' (' + repo + ') ' + pr.html_url
                send_teams_message(cfg.teams_chan, msg)
            except:
                msg = base + ' (' + repo + ') An ERROR happend while prod -> ' + base + ' PR creation'
                send_teams_message(cfg.teams_chan, msg)

    ssm.put_parameter(Name='/' + cfg.parameter_lynx,
                      Value=new_lynx_sha,
                      Type='String',
                      Overwrite=True)
    ssm.put_parameter(Name='/' + cfg.parameter_lynx_conf,
                      Value=new_lynx_conf_sha,
                      Type='String',
                      Overwrite=True)


if __name__ == "__main__":
    lambda_handler(None, None)
