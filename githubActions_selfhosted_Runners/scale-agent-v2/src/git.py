from github import Github, GithubException


class ActionsJob(dict):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.__dict__ = self


class ActionsRunner(dict):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.__dict__ = self


class GitClient:
    url = "https://api.github.com"

    def __del__(self):
        '''NO CACHING FUCK SAKE!!!!!!'''
        del self.requests

    def __init__(self, di, org, repo, token):
        self.di = di
        self.org_name = org
        self.repo_name = repo
        self.token = token
        self.headers = {"Authorization": "token {0}".format(self.token),
        'Accept': 'application/vnd.github.v3+json'}

        #EVERY INSTANCE PICK ITS OWN!!!!
        import requests
        self.requests = requests

# Obsolete?
#        self.g = Github(token)
#        self.r = self.g.get_repo("{0}/{1}".format(org, repo))
#        self.g  = Github(base_url=self.url + "/api/v3", login_or_token=token)

    def get_runners(self, condition=None):
        # pygithub does not contain get runners api reference method
        # so manually get it and hide low level api calls in the same class
        url = "{0}/repos/{1}/{2}/actions/runners".format(
            self.url, self.org_name, self.repo_name)

        response = self.requests.get(url=url, headers=self.headers)
        if response.status_code != 200:
            raise RuntimeError(
                "Could not get list of runners. sc = {0}. txt = {1}".format(
                    response.status_code, response.text))

        runners = response.json().get("runners", [])
        return [
            ActionsRunner(**r) for r in runners if r["status"] == condition
        ] if condition else runners

    def get_wf_jobs(self, id):
        url = "{0}/repos/{1}/{2}/actions/runs/{3}/jobs".format(
            self.url, self.org_name, self.repo_name, id)

        response = self.requests.get(url=url, headers=self.headers)
        if response.status_code != 200:
            raise RuntimeError(
                "Could not get list of jobs in queue. sc = {0}. txt = {1}".
                format(response.status_code, response.text))

        jobs = response.json().get("jobs", [])
        return [ActionsJob(**j) for j in jobs]

    def delete_runner(self, id):
        url = "{0}/repos/{1}/{2}/actions/runners/{3}".format(
            self.url, self.org_name, self.repo_name, id)

        response = self.requests.delete(url=url, headers=self.headers)
        if response.status_code != 204:
            raise RuntimeError(
                "Could not delete runners. sc = {0}. txt = {1}".format(
                    response.status_code, response.text))
        return

    def get_runner_join_token(self):
        url = "{0}/repos/{1}/{2}/actions/runners/registration-token".format(
            self.url, self.org_name, self.repo_name)

        self.di.logger.info('Obtaining join token. URL to obtain is: ' + url)

        response = self.requests.post(url=url, headers=self.headers)
        if response.status_code != 201:
            raise RuntimeError(
                "Could not get runner token. sc = {0}. txt = {1}".format(
                    response.status_code, response.text))

        response = self.requests.post(url=url, headers=self.headers)
        if response.status_code != 201:
            raise RuntimeError(
                "Could not get runner token. sc = {0}. txt = {1}".format(
                    response.status_code, response.text))

        self.di.logger.info(response.text)
        token = response.json().get("token")
        del response
        return token

    def get_runner_package_url(self):
        url = "{0}/repos/{1}/{2}/actions/runners/downloads".format(
            self.url, self.org_name, self.repo_name)
        response = self.requests.get(url=url, headers=self.headers)
        if response.status_code != 200:
            raise RuntimeError(
                "Could not get runner download_url. url = {0} sc = {1} txt = {2} token = {3}".
                format(url, response.status_code, response.text, str(self.headers)))

        for runner in response.json():
            if runner["os"] == "linux" and runner["architecture"] == "x64":
                return runner["download_url"]
        raise RuntimeError("Could not find valid runner for linux x64")

    def get_wf_list(self):
        wfs = self.r.get_workflows()
        return [wf for wf in wfs]

    def get_wf_runs(self):
        wf_runs = self.r.get_workflow_runs()
        return [wr for wr in wf_runs]


# run statuses: queued completed in_progress
# run conclusions: skipped success failure cancelled
