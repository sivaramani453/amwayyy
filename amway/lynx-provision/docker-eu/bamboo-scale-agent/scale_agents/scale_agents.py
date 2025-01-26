import re
import os
import sys
import boto3
import datetime
import requests
import yaml
import time
import logging
import logging.handlers as handlers
from os.path import expanduser
from json import JSONDecodeError
from collections import defaultdict
from urllib3.util.retry import Retry
from requests.adapters import HTTPAdapter
requests.packages.urllib3.disable_warnings()


def get_bamboo_credentials(path):
    with open(expanduser(path), 'r') as f:
        for line in f.readlines():
            if line.endswith('\n'):
                line = line[:-len('\n')]
            line = line.strip()
            if line.startswith('login'):
                login = line.split('=', 1)[1].strip()
            if line.startswith('password'):
                password = line.split('=', 1)[1].strip()

    return login, password


INSTANCES = []
PLAN_JOB_IDS = []

CONFIG_PATH = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'projects.yaml')
LOG_PATH = r'scale_agents.log'
TIME_TO_SLEEP = 10

AWS_REGION = 'eu-central-1'
AWS_SESSION = boto3
AWS_SSM = AWS_SESSION.client('ssm', region_name=AWS_REGION)
AWS_CLIENT = AWS_SESSION.client('ec2', region_name=AWS_REGION)
AWS_RESOURCE = AWS_SESSION.resource('ec2', region_name=AWS_REGION)
AWS_INSTANCE_PREFIX = 'CI'


AWS_CI_AUTOTEST_AMI_ID = os.getenv("CI_AUTOTEST_AMI_ID")
AWS_CI_AUTOTEST_SNAP_ID = os.getenv("CI_AUTOTEST_AMI_SNAP_ID")
AWS_CI_AUTOTEST_INST_SHAPE = os.getenv("CI_AUTOTEST_INST_SHAPE")
AWS_CI_AUTOTEST_DISK_SIZE = os.getenv("CI_AUTOTEST_DISK_SIZE")
AWS_CI_AUTOTEST_SPOT_DURATION = os.getenv("CI_AUTOTEST_SPOT_DURATION")
AWS_CI_AMI_ID = os.getenv("CI_AMI_ID")
AWS_CI_SNAP_ID = os.getenv("CI_AMI_SNAP_ID")
AWS_CI_INST_SHAPE = os.getenv("CI_INST_SHAPE")
AWS_CI_DISK_SIZE = os.getenv("CI_DISK_SIZE")
AWS_CI_SPOT_DURATION = os.getenv("CI_SPOT_DURATION")
AWS_CI_SUBNET_ID_A = os.getenv("CI_SUBNET_ID_A")
AWS_CI_SUBNET_ID_B = os.getenv("CI_SUBNET_ID_B")
AWS_CI_SUBNET_ID_C = os.getenv("CI_SUBNET_ID_C")
AWS_CI_INST_PROFILE= os.getenv("CI_INST_PROFILE")
AWS_CI_INST_KP = os.getenv("CI_INST_KP")
AWS_CI_INST_SG = os.getenv("CI_INST_SG")

AWS_CI_TAGGING = [
                    {
                    'Key': 'Schedule',
                    'Value': 'running'
                    },
                    {
                    'Key': 'DataClassification',
                    'Value': 'Internal'
                    },
                    {
                    'Key': 'ApplicationID',
                    'Value': 'APP1433689'
                    },
                    {
                    'Key': 'SEC-INFRA-13',
                    'Value': 'Appliance'
                    },
                    {
                    'Key': 'SEC-INFRA-14',
                    'Value': 'Appliance'
                    },
                    {
                    'Key': 'Environment',
                    'Value': 'DEV'
                    },
                    {
                    'Key': 'ITAM-SAM',
                    'Value': 'Appliance'
                    },
                    {
                    'Key': 'Purpose',
                    'Value': 'ContinuousIntegration'
                    }
]


BAMBOO_CRED_PATH = r'~/.bamboo/credentials'
BAMBOO_ADMIN_LOGIN, BAMBOO_ADMIN_PASSWORD = get_bamboo_credentials(BAMBOO_CRED_PATH)
BAMBOO_URL = r'https://amway-prod.tt.com.pl/bamboo/'
BAMBOO_API_URL = BAMBOO_URL + r'rest/api/latest/'
BAMBOO_AGENT_PREFIX = 'ci-machine-'


l_formatter = logging.Formatter(fmt=u'[%(asctime)s] %(levelname)-8s  %(message)s')
l_handler = handlers.RotatingFileHandler(filename=LOG_PATH,
                                         maxBytes=5*1024*1024,
                                         backupCount=5,
                                         )
l_handler.setFormatter(l_formatter)
logger = logging.getLogger('main')
logger.setLevel(logging.INFO)
logger.addHandler(l_handler)
l_handler = logging.StreamHandler(sys.stdout)
l_handler.setLevel(logging.INFO)
logger.addHandler(l_handler)
logger.info('START SCALING AGENTS')

#-------------------------------------------
AWS_SPOT_INSTANCE_TYPES = ['m5.xlarge', 'm4.xlarge',]
AWS_SPOT_PRICE_COEFFICIENT = 1.1
AWS_SUBNETS = {
    AWS_REGION + 'a': AWS_CI_SUBNET_ID_A,
    AWS_REGION + 'b': AWS_CI_SUBNET_ID_B,
    AWS_REGION + 'c': AWS_CI_SUBNET_ID_C
}

BAMBOO_AGENT_IDS = {
    '1': {'uid': '18e68f5c-8276-45dc-9984-1013ffb49a0e', 'id': '55476237'},
    '2': {'uid': '001e7836-a6cc-4766-8dbd-05a1d27ddbd3', 'id': '55476253'},
    '3': {'uid': '7b6f3c53-c1a4-4c77-a19e-9b0f391796e0', 'id': '55476254'},
    '4': {'uid': '293f1b04-68c7-4eab-8be2-282ec130544c', 'id': '55476255'},
    '5': {'uid': 'de2b4dab-f269-44fe-a0d4-5b27436b1c94', 'id': '55476256'},
    '6': {'uid': '1d26ff53-f8d1-408d-bfb3-4936161fabb9', 'id': '55476257'},
    '7': {'uid': '052b7931-ae05-497e-9dba-4ff717f12621', 'id': '55476258'},
    '8': {'uid': 'e67865f9-df84-46a8-902d-f0f2484fe3c4', 'id': '57180161'},
    '9': {'uid': '655a2ebe-fe94-46f5-8597-b8990024a642', 'id': '55476260'},
    '10': {'uid': '2a001d59-8c33-4929-8bfc-48d2eaac468c', 'id': '55476261'},
    # '11': {'uid': '68fabf0a-8746-44e6-922a-a5140c27900e', 'id': '55476262'},
    # '12': {'uid': '3bd29c60-c45b-44b0-ba52-c0c8c3061694', 'id': '55476263'},
    # '13': {'uid': '6c9c059c-1dc8-492f-a016-8c3b9f81c3aa', 'id': '55476264'},
    # '14': {'uid': '593eb810-31be-4bf8-a33b-389d6e0204ba', 'id': '55476265'},
    # '15': {'uid': '2178b5a7-542f-4e1d-9806-5f9a2feeef98', 'id': '55476266'},
    # '16': {'uid': '2b643ccf-2de7-4b67-805d-cfa4632f7219', 'id': '55476267'},
    # '17': {'uid': '2c4c081a-81cb-4b01-bdc0-a16c9765dc4c', 'id': '55476272'},
    # '18': {'uid': 'cae21304-87ae-49d7-9664-b9cbf3cbd650', 'id': '55476273'},
    # '19': {'uid': '414cc693-33b6-4585-a9a0-aff060dbfb54', 'id': '55476274'},
    # '20': {'uid': 'e65062b3-3f14-4fd3-8725-623e058afa7e', 'id': '55476275'},
    # '21': {'uid': 'c5765708-8cc7-4bfd-ae99-1d60e6d3b521', 'id': '55476276'},
    # '22': {'uid': '022757b6-b780-4d74-a2e0-d97a08daf647', 'id': '55476277'},
    # '23': {'uid': '9eee000a-e7b8-4349-b7ef-e140a2533155', 'id': '55476278'},
    # '24': {'uid': '87d3fde4-5ea4-40e3-95fd-15917382f087', 'id': '55476279'},
    # '25': {'uid': '883cc577-0e90-4ac0-9c1e-91ccf70a1509', 'id': '55476280'},
    # '26': {'uid': '48c140ad-100d-4157-8cf8-dbb8ec3bf649', 'id': '55476281'},
    # '27': {'uid': '9bfed672-96a2-4339-a218-48079e169c85', 'id': '55476282'},
    # '28': {'uid': '67585dce-be0a-4381-a0ae-81d87b0b66f7', 'id': '55476283'},
    # '29': {'uid': '583504a0-3fc4-4567-aff7-9caea2073aec', 'id': '55476284'},
    # '30': {'uid': 'ceb028d0-d4a2-43eb-b04c-d5d996055814', 'id': '55476285'},
    # '31': {'uid': '834f42f2-04fd-4c24-83ef-c3dfe0db628f', 'id': '55476286'},
    # '32': {'uid': '828b41e8-56e2-4d73-b96a-fd06a9ce464f', 'id': '55476238'},
    # '33': {'uid': 'bcfb899f-b88b-4bf8-bccc-87288da17440', 'id': '55476239'},
    # '34': {'uid': '087cf67a-42f5-469e-a118-873f7aaaac28', 'id': '55476240'},
    # '35': {'uid': '57a2940c-98c9-4a95-bd8a-48eaf8c6da5b', 'id': '55476241'},
    # '36': {'uid': 'b8db441f-20ee-470b-b7ad-c2645a468b0e', 'id': '55476268'},
    # '37': {'uid': '332baa15-f961-4acd-a289-1ed2b05b9e29', 'id': '55476242'},
    # '38': {'uid': 'feebfea1-7d09-47f5-b229-f33216e7261d', 'id': '55476243'},
    # '39': {'uid': '4672e9d3-33f0-4e85-bdb9-9494dc7b2f99', 'id': '55476244'},
    # '40': {'uid': '0bf6a0ab-0929-424e-97a3-eacc02859a7b', 'id': '55476245'},
    # '41': {'uid': '61d54431-85c4-4bf7-aecb-d42fe9f8a50e', 'id': '55476246'},
    # '42': {'uid': '3689af22-0bc3-43b9-a11b-e7682b9cbfa7', 'id': '55476247'},
    # '43': {'uid': '8f8758f9-61d1-4195-b8fe-c2a04f23b8fd', 'id': '55476248'},
    # '44': {'uid': 'd6ecb7e6-4116-4dd5-b794-75301746c66f', 'id': '55476249'},
    # '45': {'uid': 'e5eb3464-685e-4cde-995f-e9b25941ab5c', 'id': '55476250'},
    # '46': {'uid': '59d88c04-00dd-448c-bf5c-4a2d71d09dd6', 'id': '55476251'},
    # '47': {'uid': 'f7d9e4e4-42c1-4288-ac85-b4449791f866', 'id': '65568769'},
    # '48': {'uid': '9e5fb918-fae0-4bea-9891-dce345292e75', 'id': '59473926'},
    # '49': {'uid': 'cbb94170-84e1-4238-abd4-52c9856d673f', 'id': '59473927'},
    # '50': {'uid': '53c35b84-94bf-4fb6-a8cb-1cc2b1d0aa51', 'id': '65241089'},
    # '51': {'uid': '42bec501-0b1d-4f02-92cb-4fb53352c400', 'id': '65241090'},
    # '52': {'uid': 'ca32caec-c5e0-4121-a2e9-ee1502d6fe82', 'id': '65241091'},
    # '53': {'uid': '7f1f5b6f-fb7c-41c4-923c-dce724032063', 'id': '74612740'},
    # '54': {'uid': '25f66190-2d31-42f6-9f83-530453f3a4e6', 'id': '74612741'},
    # '55': {'uid': '995f26a5-8808-4cd7-b248-4acef1ff001f', 'id': '74612742'},
    # '56': {'uid': 'fd480fd7-5f9e-441c-9aef-78c1231a245b', 'id': '74612743'},
    # '57': {'uid': 'e73fc76b-d15f-4bfb-b768-2460df9f16e3', 'id': '74612744'},
    # '58': {'uid': '0d461c92-da39-4f09-9008-abcf36c229f2', 'id': '74612745'},
    # '59': {'uid': 'e7f0e0c2-73ed-46ad-bdf5-84fdbc87881d', 'id': '74612746'},
    # '60': {'uid': '57440036-f85f-4972-8cef-1e567bdd9d80', 'id': '74612747'},
    # '61': {'uid': 'e5b6b4f1-a722-44ee-b88b-a2c23ad71908', 'id': '74612748'},
    # '62': {'uid': '6fe1dda8-4155-4131-85e7-d190010e08b8', 'id': '74612749'},
    # '63': {'uid': '9a2163da-fdc7-4031-8a08-6e27fcd14d9c', 'id': '74612750'},
    # '64': {'uid': '18200b0c-756a-4cc5-9fb6-9a3aa79efb78', 'id': '74612751'},
    # '65': {'uid': '0c0785aa-2f20-4e6f-8270-fbaf983e313a', 'id': '74612752'},
    # '66': {'uid': '46afd7ee-455c-47bc-ab9a-a6124586e28f', 'id': '74612753'},
    # '67': {'uid': '8b753e3c-85c3-48c4-8b3d-58943a5e7c49', 'id': '74612754'},
    # '68': {'uid': 'fd73b4d5-49c4-4f4a-bb93-eb7edc29e64a', 'id': '74612755'},
    # '69': {'uid': '4cf0a2d3-ed8f-4dec-bb13-63dadba7fe2a', 'id': '74612756'},
    # '70': {'uid': '0510f984-f27f-428e-995b-d96105ebc4de', 'id': '74612758'},
    # '71': {'uid': '15b43932-da93-4a4a-a86d-881d8a04bb99', 'id': '74612759'},
    # '72': {'uid': 'acdb7b7c-bcd6-4074-9b0c-257e0f13beaf', 'id': '74612760'},
    # '73': {'uid': 'c4c7642b-82f7-4809-93be-58594dd0f56c', 'id': '74612761'},
    # '74': {'uid': '99ce472c-5c36-4914-a54e-418b575682dd', 'id': '74612762'},
    # '75': {'uid': 'ec4f231b-b4e8-4d5d-b3b0-9f95eff49b66', 'id': '74612763'},
}


def get_aws_spot_prices(instance_types):
    r = AWS_CLIENT.describe_spot_price_history(
        InstanceTypes=instance_types,
        ProductDescriptions=['Linux/UNIX'],
        StartTime=datetime.datetime(*time.gmtime()[:6]),
        EndTime=datetime.datetime(*time.gmtime()[:6]),
    )

    if r.get('SpotPriceHistory', None) is None:
        print('ERROR')
        return {}

    spot_prices = {}
    for i_type in instance_types:
        spot_prices[i_type] = {}

    for price in r.get('SpotPriceHistory'):
        spot_prices[price['InstanceType']].update({price['AvailabilityZone']: price['SpotPrice']})

    return spot_prices


def set_aws_instance_name(instance_id, name):
    r = AWS_CLIENT.create_tags(
        Resources=[instance_id],
        Tags=[{'Key': 'Name',
                'Value': name}]
    )
    if r['ResponseMetadata']['HTTPStatusCode'] != 200:
        logger.error("Name {} has not set to instance {}".format(name, instance_id))
        raise ConnectionError


def set_aws_parameter(name, value, type='String'):
    r = AWS_SSM.put_parameter(Name=name, Value=value, Type=type)
    if r['ResponseMetadata']['HTTPStatusCode'] != 200:
        logger.error("Parameter {} has not set".format(name))
        raise ConnectionError


def delete_aws_parameter(name):
    r = AWS_SSM.delete_parameter(Name=name)
    if r['ResponseMetadata']['HTTPStatusCode'] != 200:
        logger.error("Parameter {} has not deleted".format(name))


def create_ci_spot_instance(c_name):
    if str(c_name).startswith('autotest'):
        instance_type = AWS_CI_AUTOTEST_INST_SHAPE
        availability_zone = AWS_REGION + 'b'
        ami_id = AWS_CI_AUTOTEST_AMI_ID
        snap_id = AWS_CI_AUTOTEST_SNAP_ID
        snap_size = int(AWS_CI_AUTOTEST_DISK_SIZE)
        spot_duriation = int(AWS_CI_AUTOTEST_SPOT_DURATION)
    else:
        instance_type = AWS_CI_INST_SHAPE
        availability_zone = AWS_REGION + 'a'
        ami_id = AWS_CI_AMI_ID
        snap_id = AWS_CI_SNAP_ID
        snap_size = int(AWS_CI_DISK_SIZE)
        spot_duriation = int(AWS_CI_SPOT_DURATION)

    r = AWS_CLIENT.request_spot_instances(
        InstanceCount=1,
        BlockDurationMinutes=spot_duriation,
        LaunchSpecification={
            'ImageId': ami_id,
            'InstanceType': instance_type,
            'SubnetId': AWS_SUBNETS[availability_zone],
            'KeyName': AWS_CI_INST_KP,
            'IamInstanceProfile': {
               'Name': AWS_CI_INST_PROFILE
             },
            'BlockDeviceMappings': [
                {
                    'DeviceName': '/dev/sda1',
                    'Ebs': {
                        'DeleteOnTermination': True,
                        'VolumeType': 'gp2',
                        'VolumeSize': snap_size,
                        'SnapshotId': snap_id
                    }
                }
            ],
            'SecurityGroupIds': [
                AWS_CI_INST_SG,
            ],
            'EbsOptimized': True,
            'Monitoring': {
                'Enabled': False
            },
        },
    )

    spot_id = r['SpotInstanceRequests'][0]['SpotInstanceRequestId']
    # wait a little bit to let aws handle request properly and register it
    time.sleep(15)
    r = AWS_CLIENT.describe_spot_instance_requests(SpotInstanceRequestIds=[spot_id],)
    count = 0
    time_to_sleep = 3
    while r['SpotInstanceRequests'][0]['Status']['Code'] in ['pending-evaluation', 'pending-fulfillment']:
        time.sleep(time_to_sleep)
        r = AWS_CLIENT.describe_spot_instance_requests(SpotInstanceRequestIds=[spot_id])
        count += 1
        if count*time_to_sleep >= 60:
            logger.error("Spot request did not complete during 1 minute")
            logger.error("Last status: {}".format(r))
            raise TimeoutError

    if r['SpotInstanceRequests'][0]['Status']['Code'] == 'failed':
        logger.error('Run instance has ended with code "failed"')
        logger.error(r)
        raise Exception

    if r['SpotInstanceRequests'][0].get('InstanceId', None) is None:
        logger.error('Spot request had not had "InstanceId" block')
        logger.error(r)
        raise Exception

    instance_id = r['SpotInstanceRequests'][0]['InstanceId']
    instance_price = r['SpotInstanceRequests'][0]['ActualBlockHourlyPrice']
    set_aws_parameter(instance_id, '{id},{uid}'.format(**BAMBOO_AGENT_IDS[c_name]))
    set_aws_instance_name(instance_id, AWS_INSTANCE_PREFIX + c_name)

    AWS_CLIENT.create_tags(
        Resources = [instance_id],
        Tags = AWS_CI_TAGGING
    )

    return instance_id, str(float(instance_price))


def create_ci_ondemand_instance(c_name):
    instance_type = AWS_CI_INST_SHAPE
    availability_zone = AWS_REGION + 'a'
    ami_id = AWS_CI_AMI_ID
    snap_id = AWS_CI_SNAP_ID
    snap_size = int(AWS_CI_DISK_SIZE)

    r = AWS_RESOURCE.create_instances(
        ImageId = ami_id,
        InstanceType = instance_type,
        SubnetId = AWS_SUBNETS[availability_zone],
        KeyName = AWS_CI_INST_KP,
        MaxCount = 1,
        MinCount = 1,
        IamInstanceProfile = {
            "Name": AWS_CI_INST_PROFILE
        },
        BlockDeviceMappings = [
            {
                'DeviceName': '/dev/sda1',
                'Ebs': {
                    'DeleteOnTermination': True,
                    'VolumeType': 'gp2',
                    'VolumeSize': snap_size,
                    'SnapshotId': snap_id
                }
            }
        ],
        SecurityGroupIds = [
            AWS_CI_INST_SG,
        ],
        EbsOptimized = True,
        Monitoring = {
        'Enabled': False
        },
        TagSpecifications=[
        {
            'ResourceType': 'instance',
            'Tags': AWS_CI_TAGGING
        },
        ],
    )
  
    ondemand_id = r[0].id
    time.sleep(15)
    r = AWS_CLIENT.describe_instances(InstanceIds=[ondemand_id])
    count = 0
    time_to_sleep = 3
    while r['Reservations'][0]['Instances'][0]['State']['Name'] in ['pending']:
        time.sleep(time_to_sleep)
        r = AWS_CLIENT.describe_instances(InstanceIds=[ondemand_id])
        count += 1
        if count*time_to_sleep >= 60:
            logger.error("Ondemand instance did not rise in 1 minute")
            logger.error("Last status: {}".format(r))
            raise TimeoutError

    if r['Reservations'][0]['Instances'][0].get('InstanceId', None) is None:
        logger.error('Ondemand instance does not have "InstanceId" block')
        logger.error(r)
        raise Exception

    instance_id = r['Reservations'][0]['Instances'][0]['InstanceId']
    set_aws_parameter(instance_id, '{id},{uid}'.format(**BAMBOO_AGENT_IDS[c_name]))
    set_aws_instance_name(instance_id, AWS_INSTANCE_PREFIX + c_name)
    return instance_id


def disable_bamboo_agents_on_spot(bamboo_online_agents):
    agent_ids = [agent['id'] for agent in bamboo_online_agents if agent['enabled'] and agent['busy']
                 and convert_bamboo_to_common_name(agent['name']) in BAMBOO_AGENT_IDS.keys()]
    for id in agent_ids:
        disable_bamboo_agent(id)


# AWS_SPOT_PRICES = get_aws_spot_prices(AWS_SPOT_INSTANCE_TYPES)

#-------------------------------------------------------------------------------------------------------


def get_names_with_prefix(prefix, names):
    return [ prefix + name for name in names ]


def get_dict_with_status_instances():
    paginator = AWS_CLIENT.get_paginator('describe_instances')

    paginator_iter = paginator.paginate(
        Filters=[
            {
                'Name': 'tag:Name',
                'Values': AWS_INSTANCES
            }
        ],
    )

    instances = defaultdict(list)
    spot_instance_c_names = list(BAMBOO_AGENT_IDS.keys())
    bamboo_disabled_free_agents_c_name = {}
    for agent in bamboo_disabled_free_agents:
        bamboo_disabled_free_agents_c_name[convert_bamboo_to_common_name(agent['name'])] = agent['id']
    for statuses in paginator_iter:
        for status in statuses['Reservations']:
            state_instance = status['Instances'][0]['State']['Name']
            instance_id = status['Instances'][0]['InstanceId']
            #name = status['Instances'][0]['Tags'][0]['Value']
            for tags in status['Instances'][0]['Tags']:
                if tags['Key'] == 'Name':
                    name = tags['Value']
            common_name = convert_aws_to_common_name(name)

            if common_name in bamboo_disabled_free_agents_c_name.keys() and common_name in spot_instance_c_names \
                    and str(instance_id) not in DISABLED_AGENTS.keys():
                # stop_aws_instance(instance_id, common_name)
                # bamboo_id = bamboo_disabled_free_agents_c_name[common_name]
                # if not enable_bamboo_agent(bamboo_id):
                #     logger.error(u"ERROR Agent {} was not enabled!".format(bamboo_id))
                # state_instance = 'terminated'
                projects_result_dict_list['stop'].append({
                    'instanceId': instance_id,
                    'bambooAgentId': bamboo_disabled_free_agents_c_name[common_name],
                    'commonName': common_name,
                })

            if common_name in spot_instance_c_names:
                spot_instance_c_names.remove(common_name)

            if state_instance == 'running':
                if common_name in COMMON_NAME_RUNNING_INSTANCES:
                    state_instance = 'pending'

            if state_instance == 'terminated':
                if str(instance_id) in DISABLED_AGENTS.keys():
                    bamboo_id = DISABLED_AGENTS.pop(instance_id)
                    if not enable_bamboo_agent(bamboo_id):
                        logger.error(u"ERROR Agent {} was not enabled!".format(bamboo_id))

                new_name = 'terminated_{}{}'.format(AWS_INSTANCE_PREFIX, common_name)
                set_aws_instance_name(instance_id, new_name)
                delete_aws_parameter(str(instance_id))

            instances[state_instance].append({
                                            'instanceId': instance_id,
                                            'name': name,
                                            'commonName': common_name,
            })

            if state_instance not in ['stopping', 'shutting-down'] and str(instance_id) in DISABLED_AGENTS.keys():
                bamboo_id = DISABLED_AGENTS.pop(instance_id)
                if not enable_bamboo_agent(bamboo_id):
                    logger.error(u"ERROR Agent {} was not enabled!".format(bamboo_id))


    for common_name in spot_instance_c_names:
        if common_name in INSTANCES:
            instances['stopped'].insert(0, {
                'instanceId': None,
                'name': '{}{}'.format(AWS_INSTANCE_PREFIX, common_name),
                'commonName': common_name,
            })
            if common_name in bamboo_disabled_free_agents_c_name.keys():
                bamboo_id = bamboo_disabled_free_agents_c_name[common_name]
                if not enable_bamboo_agent(bamboo_id):
                    logger.error(u"ERROR Agent {} was not enabled!".format(bamboo_id))

    return instances


def get_bamboo_online_agents():
    retries = Retry(
        total=5, 
        connect=10,
        backoff_factor=2,
        status_forcelist=[ 429, 500, 502, 503, 504 ]
    )
    adapter = HTTPAdapter(max_retries=retries)
    http = requests.Session()
    http.mount("https://", adapter)
    http.mount("http://", adapter)

    try:
        r = http.get(BAMBOO_API_URL + r'agent?online=true',
                        auth=(BAMBOO_ADMIN_LOGIN, BAMBOO_ADMIN_PASSWORD),
                        verify=False)
    except Exception as err:
        logger.error("Couldn't get list of online agents. Reason is: {}.".format(err))

    return r.json()


def get_bamboo_disabled_agents():
    retries = Retry(
        total=5, 
        connect=10,
        backoff_factor=2,
        status_forcelist=[ 429, 500, 502, 503, 504 ]
    )
    adapter = HTTPAdapter(max_retries=retries)
    http = requests.Session()
    http.mount("https://", adapter)
    http.mount("http://", adapter)

    try:
        r = http.get(BAMBOO_API_URL + r'agent',
                        auth=(BAMBOO_ADMIN_LOGIN, BAMBOO_ADMIN_PASSWORD),
                        verify=False)
    except Exception as err:
        logger.error("Couldn't get list of disabled agents. Reason is: {}.".format(err))

    return [agent for agent in r.json() if not agent['enabled'] and not agent['busy']]


def get_queue_count():
    retries = Retry(
        total=5, 
        connect=10,
        backoff_factor=2,
        status_forcelist=[ 429, 500, 502, 503, 504 ]
    )
    adapter = HTTPAdapter(max_retries=retries)
    http = requests.Session()
    http.mount("https://", adapter)
    http.mount("http://", adapter)

    try:
        r = http.get(BAMBOO_API_URL + 'queue.json?expand=queuedBuilds',
                        auth=(BAMBOO_ADMIN_LOGIN, BAMBOO_ADMIN_PASSWORD),
                        verify=False)
    except Exception as err:
        logger.error("Couldn't get build queue length. Reason is: {}.".format(err))

    queued_builds = [ build['planKey'] for build in r.json()['queuedBuilds']['queuedBuild'] ]
    queued_builds_line = ' ' + '  '.join(queued_builds) + ' '
    count = 0
    for job_id in PLAN_JOB_IDS:
        job_id = job_id.rstrip('-')
        levels = job_id.split('-')
        if len(levels) == 1:
            pattern = " {}-.+?-.+?".format(levels[0])
        elif len(levels) == 2:
            pattern = " {}-{}[0-9]*-.+?".format(levels[0], levels[1])
        else:
            pattern = " {}-{}[0-9]*-{} ".format(levels[0], levels[1], '-'.join(levels[2:]))

        count += len(re.findall(pattern, queued_builds_line))

    return count


def get_dict_agents(bamboo_online_agents):
    bamboo_agents_dict = {}
    for agent in bamboo_online_agents:
        if agent['name'] in BAMBOO_AGENTS:
            if agent['enabled'] or convert_bamboo_to_common_name(agent['name']) in BAMBOO_AGENT_IDS.keys():
                common_name = convert_bamboo_to_common_name(agent['name'])
                if common_name in COMMON_NAME_RUNNING_INSTANCES:
                    COMMON_NAME_RUNNING_INSTANCES.remove(common_name)

                if not agent['busy']:
                    bamboo_agents_dict[common_name] = {
                        'id': agent['id'],
                        'name': agent['name'],
                    }

    return bamboo_agents_dict


def convert_bamboo_to_aws_names(bamboo_names):
    return [ AWS_INSTANCE_PREFIX + name[len(BAMBOO_AGENT_PREFIX):] for name in bamboo_names ]


def convert_aws_to_bamboo_name(aws_name):
    return BAMBOO_AGENT_PREFIX + convert_aws_to_common_name(aws_name)


def convert_aws_to_common_name(name):
    return name[len(AWS_INSTANCE_PREFIX):]


def convert_bamboo_to_common_name(name):
    return name[len(BAMBOO_AGENT_PREFIX):]


def stop_aws_instance(instance_id, c_name):
    instance_aws = AWS_RESOURCE.Instance(instance_id)

    if c_name in BAMBOO_AGENT_IDS.keys():
        log_str = u'Terminate instance {}{}: {}'.format(AWS_INSTANCE_PREFIX, c_name, str(instance_id))
        logger.info(log_str)
        instance_aws.terminate()
    else:
        log_str = u'Stop instance {}{}: {}'.format(AWS_INSTANCE_PREFIX, c_name, str(instance_id))
        logger.info(log_str)
        instance_aws.stop()


def start_aws_instances(dict_instances_to_start):
    if not dict_instances_to_start:
        logger.info(u"All stopped instances were started")
        return

    for instance in dict_instances_to_start:
        instance_price = '0.23'
        if instance['commonName'] in BAMBOO_AGENT_IDS.keys():
            if str(instance['commonName']).startswith('autotest'):
                instance['instanceId'], instance_price = create_ci_spot_instance(instance['commonName'])
            else:
                instance['instanceId'] = create_ci_ondemand_instance(instance['commonName'])    
        else:    
            instance_aws = AWS_RESOURCE.Instance(instance['instanceId'])
            instance_aws.start()

        log_str = u"Started instance {}{}: {}".format(AWS_INSTANCE_PREFIX, instance['commonName'], str(instance['instanceId']))
        logger.info(log_str)
        if instance['commonName'] not in COMMON_NAME_RUNNING_INSTANCES:
            COMMON_NAME_RUNNING_INSTANCES.append(instance['commonName'])


def disable_bamboo_agent(agent_id):
    retries = Retry(
        total=5, 
        connect=10,
        backoff_factor=2,
        status_forcelist=[ 429, 500, 502, 503, 504 ]
    )
    adapter = HTTPAdapter(max_retries=retries)
    http = requests.Session()
    http.mount("https://", adapter)
    http.mount("http://", adapter)

    try:
        response = http.get(BAMBOO_URL + r'admin/agent/disableAgent.action?agentId={}'.format(agent_id),
                        auth=(BAMBOO_ADMIN_LOGIN, BAMBOO_ADMIN_PASSWORD),
                        verify=False)
    except Exception as err:
        logger.error("Remote Agent with id: {} hasn't been disabled. Reason is: {}.".format(agent_id, err))

    logger.info("DISABLE: {}. Status Code: {}.".format(agent_id, response.status_code))

    return response.ok


def enable_bamboo_agent(agent_id, attempts=2):
    r = requests.get(BAMBOO_URL + r'admin/agent/enableAgent.action?agentId={}'.format(agent_id),
                     auth=(BAMBOO_ADMIN_LOGIN, BAMBOO_ADMIN_PASSWORD),
                     verify=False)
    if not r.ok:
        if attempts > 1:
            log_str = "{} was not enabled. Still attempts: {}".format(agent_id, attempts - 1)
            logger.warning(log_str)
            enable_bamboo_agent(agent_id, attempts-1)
        else:
            return False

    r = requests.get(BAMBOO_API_URL + r'agent?online=true',
                     auth=(BAMBOO_ADMIN_LOGIN, BAMBOO_ADMIN_PASSWORD),
                     verify=False)
    if not r.ok or r.json() is None:
        if attempts > 1:
            log_str = "{} was not enabled. Still attempts: {}".format(agent_id, attempts - 1)
            logger.warning(log_str)
            enable_bamboo_agent(agent_id, attempts - 1)
        else:
            return False

    for agent in r.json():
        if agent['id'] == agent_id:
            log_str = u'ENABLE: ' + str(agent_id)
            logger.info(log_str)
            return agent['enabled'] is True
    return False


def gen_result_dict(command, aws, bamboo):
    result_dict = defaultdict(list)
    for instance in aws:
        result_dict[command].append({
            'instanceId': instance['instanceId'],
            'bambooAgentId': bamboo.get(instance['commonName'], {}).get('id', ''),
            'commonName': instance['commonName'],
        })

    return result_dict


def subtraction_lists(list, sub_list):
    copy_sub_list = sub_list.copy()
    copy_list = list.copy()
    result_list = copy_list
    for v in list:
        if v in copy_sub_list:
            copy_list.remove(v)
            copy_sub_list.remove(v)
    return result_list


def agents_to_scale(aws_states, queue_count, bamboo_online_agents):
    bamboo_agents = get_dict_agents(bamboo_online_agents)
    aws_running_common_name = [aws['commonName'] for aws in aws_states['running']]
    bamboo_common_name = [c_name for c_name in bamboo_agents.keys()]
    free_agents_c_name = list(set(aws_running_common_name) & set(bamboo_common_name))
    project_result_agents = {}

    if queue_count == 0:
        max_free_agents = COUNT_MAX_FREE_AGENTS
        max_free_agents -= len(aws_states.get('pending', []))
        max_free_agents = 0 if max_free_agents < 0 else max_free_agents

        if len(free_agents_c_name) == max_free_agents:
            log_str = 'OK, free agents: ' + str(free_agents_c_name) + 'max free agents: ' + str(max_free_agents)
            logger.info(log_str)

        elif len(free_agents_c_name) > max_free_agents:
            aws_instance_names_to_stop = get_names_with_prefix(AWS_INSTANCE_PREFIX, free_agents_c_name[max_free_agents:])

            running_aws_names = [ instance['name'] for instance in aws_states['running'] ]
            running_aws_instance_name_to_stop = list(set(running_aws_names) & set(aws_instance_names_to_stop))

            aws_instances_to_stop = list(filter(lambda x: x['name'] in running_aws_instance_name_to_stop,
                                                aws_states['running']))

            project_result_agents = gen_result_dict('stop', aws_instances_to_stop, bamboo_agents)

        else:
            aws_to_start_count = max_free_agents if max_free_agents <= len(aws_states.get('stopped', [])) \
                else len(aws_states.get('stopped', []))

            project_result_agents = gen_result_dict('start', aws_states.get('stopped', [])[:aws_to_start_count],
                                                    bamboo_agents)
    else:
        queue_count -= len(aws_states.get('pending', []))
        queue_count = 0 if queue_count < 0 else queue_count

        # bamboo_disabled_free_agents_c_name = [ convert_bamboo_to_common_name(agent) for agent in bamboo_disabled_free_agents ]
        # aws_instance_names_to_stop =  get_names_with_prefix(AWS_INSTANCE_PREFIX, bamboo_disabled_free_agents_c_name)
        # running_aws_names = [instance['name'] for instance in aws_states['running']]
        # running_aws_instance_name_to_stop = list(set(aws_instance_names_to_stop) & set(running_aws_names))
        # aws_instances_to_stop = list(filter(lambda x: x['name'] in running_aws_instance_name_to_stop,
        #                                     aws_states['running']))
        # project_result_agents = gen_result_dict('stop', aws_instances_to_stop, bamboo_agents)

        aws_to_start_count = queue_count if queue_count <= len(aws_states.get('stopped', [])) \
            else len(aws_states.get('stopped', []))

        if aws_to_start_count != 0:
            project_result_agents = gen_result_dict('start', aws_states.get('stopped', [])[:aws_to_start_count],
                                                    bamboo_agents)

    return project_result_agents.get('start', []), project_result_agents.get('stop', [])


def scale_agents(projects_result):
    stop_c_names_list = []
    start_c_names_list = []
    for project in projects_result['stop']:
        stop_c_names_list.append(project['commonName'])

    for project in projects_result['start']:
        start_c_names_list.append(project['commonName'])

    to_start_c_names_list = list(set(subtraction_lists(start_c_names_list, stop_c_names_list)))
    to_stop_c_names_list = list(set(subtraction_lists(stop_c_names_list, start_c_names_list)))

    if to_start_c_names_list:
        instances_to_start = []
        for project in projects_result['start']:
            if project['commonName'] in to_start_c_names_list:
                instances_to_start.append(project)
                to_start_c_names_list.remove(project['commonName'])

        start_aws_instances(instances_to_start)

    if to_stop_c_names_list:
        instances_to_stop = []
        for project in projects_result['stop']:
            if project['commonName'] in to_stop_c_names_list:
                instances_to_stop.append(project)
                to_stop_c_names_list.remove(project['commonName'])

        for to_stop in instances_to_stop:
            disable_bamboo_agent(to_stop['bambooAgentId'])

        time.sleep(60)
        online_agents = get_bamboo_online_agents()

        free_agent_ids = [agent['id'] for agent in online_agents if not agent['busy']]

        for to_stop in instances_to_stop:
            if to_stop['bambooAgentId'] in free_agent_ids:
                stop_aws_instance(to_stop['instanceId'], to_stop['commonName'])
                DISABLED_AGENTS[str(to_stop['instanceId'])] = to_stop['bambooAgentId']
            else:
                if not enable_bamboo_agent(to_stop['bambooAgentId']):
                    logger.error(u"ERROR Agent {} was not enabled!".format(to_stop['bambooAgentId']))


with open(CONFIG_PATH, 'r') as f:
    conf = ''
    for line in f.readlines():
        conf += line

yaml_conf = yaml.safe_load(conf)

COMMON_NAME_RUNNING_INSTANCES = []
DISABLED_AGENTS = {}
common_count = 0
while True:
    try:
        if common_count*TIME_TO_SLEEP >= 600:
            common_count = 0
            # AWS_SPOT_PRICES = get_aws_spot_prices(AWS_SPOT_INSTANCE_TYPES)

        bamboo_online_agents_ = get_bamboo_online_agents()
        bamboo_disabled_free_agents = get_bamboo_disabled_agents()
        projects_result_dict_list = defaultdict(list)
        disable_bamboo_agents_on_spot(bamboo_online_agents_)

        for project in yaml_conf.values():
            INSTANCES = [ str(instance) for instance in project['instances'] ]
            PLAN_JOB_IDS = [ str(job_id) for job_id in project['job_ids'] ]
            COUNT_MAX_FREE_AGENTS = project['free_agents']

            AWS_INSTANCES = get_names_with_prefix(AWS_INSTANCE_PREFIX, INSTANCES)
            BAMBOO_AGENTS = get_names_with_prefix(BAMBOO_AGENT_PREFIX, INSTANCES)

            queue_count_ = get_queue_count()
            aws_states_ = get_dict_with_status_instances()

            start, stop = agents_to_scale(aws_states_, queue_count_, bamboo_online_agents_)
            projects_result_dict_list['start'].extend(start)
            projects_result_dict_list['stop'].extend(stop)

        scale_agents(projects_result_dict_list)
        log_str = 'Running instances: ' + ', '.join(COMMON_NAME_RUNNING_INSTANCES)
        logger.info(log_str)
        log_str = 'Disabled agents: ' + ', '.join([str(x) for x in DISABLED_AGENTS.values()])
        logger.info(log_str)
    except requests.ConnectionError as e:
        logger.error("Connection ERROR. Reason is: {}.".format(e))
    except JSONDecodeError as e:
        logger.error("Json data is None. Reason is: {}.".format(e))
    except Exception as e:
        logger.error("Unknown type. Reason is: {}.".format(e))

    common_count += 1
    time.sleep(TIME_TO_SLEEP)
