import os


class Logger:
    name = "main"


class Teams:
    url = "https://epam.webhook.office.com/webhookb2/{chan}/IncomingWebhook/{secret}"
    chan = {
        "eu": "f96ab52f-f6a2-46f6-9063-6fd2bde0ce30@b41b72d0-4e9f-4c26-8a69-f949f367c91d"
    }
    secret = os.environ.get("TEAMS_SECRET")


class Skype:
    url = "https://touch.epm-esp.projects.epam.com/bot-esp/message"
    chan = {"eu": "pullrequests"}
    secret = os.environ.get("SKYPE_SECRET")


class RepoEurope:
    name = "AmwayACS/lynx"
    statuses = 5
    config_name = "AmwayACS/lynx-config"
    branches = ["dev-dev", "dev-rel", "support-dev", "support-rel"]

class DynamoDB:
    tablename = os.environ.get("DYNAMODB_TABLE")
    region = "eu-central-1"

class DynamoDBUsers:
    tablename = "gh_users"
    region = "eu-central-1"

class SSMParameter:
    region = "eu-central-1"


class config:
    logger = Logger
    skype = Skype
    teams = Teams
    dynamo = DynamoDB
    ssmparameter = SSMParameter
    repo = {"eu": RepoEurope}
    dynamodbusers = DynamoDBUsers
