import boto3
import datetime
import re
import os

def handler(event, context):
    days_to_store = int(os.getenv("RETENTION_PERIOD"))
    instances = ['dev_euv*', 'dev_ruv*', 'dev_aiu*', 'dev_plu*']
    ec2r = boto3.resource('ec2')
    now = datetime.datetime.today()

    filters = [
        {
            'Name': 'tag:Name',
            'Values': instances
        },
        {
            'Name': 'instance-state-name',
            'Values': ['stopped']
        }
    ]

    stopped_instances = ec2r.instances.filter(Filters=filters)
    for instance in stopped_instances:
        for tag in instance.tags:
            if 'Name' in tag['Key']:
                instance_name = tag['Value']
        tr = instance.state_transition_reason
        stopped_time_str = (re.findall('.*\((.*)\)', tr)[0])
        stopped_time = datetime.datetime.strptime(stopped_time_str, '%Y-%m-%d %H:%M:%S %Z')
        delta = now - stopped_time
        diff = delta.days
        print('Instance:', instance_name)
        print('    Stopped time:', stopped_time)
        print('    Stopped for:', diff, ' days')

        if diff >= days_to_store:
            print(f"Terminating instance {instance_name} as it was stopped at {stopped_time}")
            instance.terminate()


if __name__ == "__main__":
    handler(None, None)            
