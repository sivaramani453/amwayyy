import boto3
import json
import os
import requests
from botocore.exceptions import ClientError
from datetime import datetime, timezone, timedelta

requests.packages.urllib3.disable_warnings()

warning_messages = False

MESSAGE_CHAT_NAME = os.getenv('MESSAGE_CHAT_NAME')
MESSAGE_CHAT_PASSWORD = os.getenv('MESSAGE_CHAT_PASSWORD')
MESSAGE_SERVER_URL = os.getenv('MESSAGE_SERVER_URL')


def format_delta(duration):
    days, seconds = duration.days, duration.seconds
    hours = seconds // 3600
    minutes = (seconds % 3600) // 60
    return f"{days} days, {hours}hours, {minutes}m"


def send_message_to_skype(message):
    data = {
        'channel': MESSAGE_CHAT_NAME,
        'secret': MESSAGE_CHAT_PASSWORD,
        'type': 'simple',
        'text': message
    }
    r = requests.post(MESSAGE_SERVER_URL,
                      headers={'Content-Type': 'application/json', 'accept-version': '1.0.0'},
                      data=json.dumps(data),
                      verify=False)


def handler(event, context):
    delta_limit_sec = int(os.getenv('RUN_LIMIT_SEC'))
    delta_limit = timedelta(seconds=delta_limit_sec)
    current_time = datetime.now(timezone.utc)


    try:
        ec2r = boto3.resource('ec2')
        running_instances = [i for i in ec2r.instances.filter(
            Filters=[{'Name': 'instance-state-name', 'Values': ['running']}])]
        scheduled_instances = [i for i in ec2r.instances.filter(
            Filters=[{'Name': 'instance-state-name', 'Values': ['running']},
                     {'Name': 'tag-key', 'Values': ['Schedule']}])]

        unscheduled_instances = [instance for instance in running_instances
                                 if instance.id not in [i.id for i in scheduled_instances]]
    except ClientError as e:
        print(f"Unexpected error: {e}")
        exit(1)

    message = ''
    # Actual count of offending instances
    offenders_count = 0

    for instance in unscheduled_instances:
        launch_time = instance.launch_time
        delta = current_time - launch_time
        if delta > delta_limit:
            offenders_count += 1
            tags = instance.tags

            # Checking the case when there are no any tags
            name_list = []

            if tags is not None:
                name_list = [tag['Value'] for tag in tags if tag['Key'] == 'Name']

            name = '' if len(name_list) == 0 else name_list[0]
            message_item = f"ID: {instance.id}, Name: '{name}', Time running: {format_delta(delta)}"
            message = message + message_item + '<br/>'

    print(f"Unscheduled instances count: {len(unscheduled_instances)}, offending instances count: {offenders_count}")

    if offenders_count > 0:
        message = f"List of instances which run longer than {delta_limit_sec} seconds:" + '<br/>' + message
        send_message_to_skype(message)
