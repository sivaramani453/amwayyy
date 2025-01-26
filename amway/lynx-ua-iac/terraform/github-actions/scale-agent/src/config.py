import os


class RunnerConfig:
    user = "github"
    group = "github"
    workdir = "ga"


class GitConfig:
    org = os.getenv("GIT_ORG")
    repo = os.getenv("GIT_REPO")
    token = os.getenv("GIT_TOKEN")


class AWSConfig:
    region = os.getenv("INSTANCE_REGION", "eu-central-1")
    instance_type = os.getenv("INSTANCE_TYPE")
    ami = os.getenv("INSTANCE_AMI")
    disk_size = os.getenv("INSTANCE_DISK_SIZE", "30")
    subnet = os.getenv("INSTANCE_SUBNET")
    kp = os.getenv("INSTANCE_KP", "EPAM-SE")
    sg = os.getenv("INSTANCE_SG")
    iam_profile = {
        "Name": os.getenv("INSTANCE_PROFILE")
    }


class Dynamodb:
    region = os.getenv("DYNAMODB_REGION", "eu-central-1")
    tablename = os.getenv("DYNAMODB_TABLE")


class Skype:
    url = os.getenv("SKYPE_URL")
    chan = os.getenv("SKYPE_CHAN")
    secret = os.getenv("SKYPE_SECRET")


class config:
    git = GitConfig
    aws = AWSConfig
    runner = RunnerConfig
    dynamodb = Dynamodb
    skype = Skype
