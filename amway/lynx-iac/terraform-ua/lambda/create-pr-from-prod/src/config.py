import os


class Config:
    org = os.environ.get("ORG", "AmwayACS")
    ref = os.environ.get("REF", "prod")
    github_api_token = os.environ.get("GITHUB_API_TOKEN", None)
    teams_chan = os.environ.get("TEAMS_CHANNEL", None)
    branches = os.environ.get("BRANCHES", "")
    parameter_lynx = os.environ.get("PARAMETER_LYNX", None)
    parameter_lynx_conf = os.environ.get("PARAMETER_LYNX_CONF", None)
    code_repo = os.environ.get("CODE_REPO", "")
    config_repo = os.environ.get("CONFIG_REPO", "")

    def __init__(self):
        if not self.github_api_token:
            raise RuntimeError("Github token not found")


if __name__ == "__main__":
    c = Config()
