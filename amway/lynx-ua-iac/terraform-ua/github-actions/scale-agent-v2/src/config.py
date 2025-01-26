import os

class RunnerConfig:
    user = "github"
    group = "github"
    workdir = "ga"

class GitConfig:
    token = os.getenv("GIT_TOKEN")
    secret = os.getenv("GIT_SECRET")

class AWSConfig:
    region = os.getenv("INSTANCE_REGION", "eu-central-1")
    instance_type = os.getenv("INSTANCE_TYPE")
    ami = os.getenv("INSTANCE_AMI")
    disk_size = int(os.getenv("INSTANCE_DISK_SIZE", 30))
    subnet = os.getenv("INSTANCE_SUBNET")
    kp = os.getenv("INSTANCE_KP", "EPAM-SE")
    sg = os.getenv("INSTANCE_SG")
    maxprice = os.getenv("SPOT_MAXPRICE", "0.04")
    duration = os.getenv("SPOT_DURATION", "180")
    # above ^ gets to the BlockDurationMinutes parameter
    # and needs to be multiplication of 60, like 60, 120, 180 etc
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

class Teams:
    url = os.getenv("TEAMS_WEBHOOK_URL")

class config:
    git = GitConfig
    aws = AWSConfig
    runner = RunnerConfig
    dynamodb = Dynamodb
    skype = Skype
    teams = Teams
