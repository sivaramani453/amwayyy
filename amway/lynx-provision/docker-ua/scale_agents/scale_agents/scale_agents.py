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
AWS_SSM = AWS_SESSION.client('ssm')
AWS_CLIENT = AWS_SESSION.client('ec2', region_name=AWS_REGION)
AWS_RESOURCE = AWS_SESSION.resource('ec2', region_name=AWS_REGION)
AWS_INSTANCE_PREFIX = 'CI'


AWS_CI_AUTOTEST_AMI_ID = 'ami-05d72def6c54bc7b8'
AWS_CI_AUTOTEST_SNAP_ID = 'snap-0db8d60eb520cfa13'
AWS_CI_AMI_ID = 'ami-0043290d1053becc4'
AWS_CI_SNAP_ID = 'snap-039b5592041e4d84f'

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
                    'Value': 'APP3150571'
                    },
                    {
                    'Key': 'SEC-INFRA-13',
                    'Value': 'Appliance'
                    },
                    {
                    'Key': 'SEC-INFRA-14',
                    'Value': 'MSP'
                    },
                    {
                    'Key': 'Environment',
                    'Value': 'DEV'
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
    AWS_REGION + 'a': 'subnet-0be51a63',
    AWS_REGION + 'b': 'subnet-bc84f7c1',
    AWS_REGION + 'c': 'subnet-5993d314'
}

BAMBOO_AGENT_IDS = {
    '76': {'uid': '1b42573f-2c4e-4d0e-90c9-507a065b7f2f', 'id': '74612764'},
    '77': {'uid': '1f7084ae-2d13-42a4-b7ea-b69840ff0858', 'id': '74612765'},
    '78': {'uid': 'dfc32612-8134-41f8-95ce-47ff94b0bda1', 'id': '74612766'},
    '79': {'uid': '6929fcff-908b-4e2a-ab26-cbf3db7167d2', 'id': '74612767'},
    '80': {'uid': '49bc7f3c-7d3e-4e9d-9801-4b964259154c', 'id': '74612768'},
    '81': {'uid': '1b37f586-5bbc-476f-8b67-e14896f62307', 'id': '74612769'},
    '82': {'uid': 'bde809a6-47d3-4ad6-a29c-ff10be601e23', 'id': '74612770'},
    '83': {'uid': 'e082f198-7144-4974-b8a1-a817822b559b', 'id': '74612771'},
    '84': {'uid': 'c060ac91-ffb8-4c24-a961-33b0ec837279', 'id': '74612772'},
    '85': {'uid': '4ff3eeac-6f3d-4f43-a949-8f70cc4b4d27', 'id': '74612773'},
    '86': {'uid': 'f13d9138-5398-473c-b6d2-3db71f8e9c29', 'id': '74612774'},
    '87': {'uid': 'f573686e-c3bc-490e-89a7-2332a4ad1c35', 'id': '74612775'},
    '88': {'uid': '1be1a423-7bea-4190-bf84-527443026e18', 'id': '74612776'},
    '89': {'uid': '0e1aba8d-9f00-488d-9de1-33a2d248ef77', 'id': '74612777'},
    '90': {'uid': 'b0074648-ef9b-475d-9254-f138cf91a972', 'id': '74612778'},
    '91': {'uid': '6b49bd04-d87e-43ba-ad77-69b8e29bf389', 'id': '74612779'},
    '92': {'uid': '690c9c5a-cef5-43e0-834d-117fbab044fc', 'id': '74612780'},
    '93': {'uid': '7b8dfaee-27de-40ff-b275-70c43f571dba', 'id': '74612781'},
    '94': {'uid': 'cfa32828-4307-4b78-b78a-21ad227e4620', 'id': '74612782'},
    '96': {'uid': 'afc7a8c8-5521-4c1d-93d6-b724f0577043', 'id': '74612784'},
    '97': {'uid': '349b2435-9c4a-4b59-8f9b-06cb8559e920', 'id': '74612785'},
    '98': {'uid': '4abb9923-bdaf-43cc-8a27-29e4c1aa92df', 'id': '74612786'},
    '99': {'uid': '4b0bdb2a-d5a7-4729-865b-4235a9eec631', 'id': '74612787'},
    '100': {'uid': '8b5983c8-5851-46b2-9a61-f00bc16a58a0', 'id': '74612788'},
    '101': {'uid': '9c753c87-c5f0-48bb-97dd-8c400d9476ff', 'id': '74612789'},
    '102': {'uid': 'c2729a5f-f72e-4541-ad7b-c6dd73d8cfef', 'id': '74612790'},
    '103': {'uid': '86b13366-8532-4a27-a3a9-ec3c872d475f', 'id': '74612791'},
    '104': {'uid': 'a7da7398-ec27-4658-9fc1-e84b1e0424b8', 'id': '74612792'},
    '105': {'uid': '576b7fac-ac02-4e25-a100-ad47f31d2bb2', 'id': '74612793'},
    '106': {'uid': 'c97f304b-c562-4e8f-8047-7ae99378e765', 'id': '74612794'},
    '107': {'uid': '5b311426-eba8-4b9f-bf30-af71bc9590ea', 'id': '74612795'},
    '108': {'uid': '8037c359-d917-43c6-8ef0-34a37c45d2ff', 'id': '74612796'},
    '109': {'uid': '0dba4b5a-42db-42fd-86ef-32d7d01de7bd', 'id': '74612797'},
    '110': {'uid': 'b42f1327-6bed-4c0a-97cb-f2e89820d473', 'id': '74612798'},
    '111': {'uid': '86a2a79c-f95f-4919-a39e-40d19d9de460', 'id': '74612799'},
    '112': {'uid': '9730f238-dcaf-4f7b-be1c-8401dfad31db', 'id': '74612800'},
    '113': {'uid': '7ef0bccf-38f9-4d23-aa00-50d8a248bfd8', 'id': '118685825'},
    '114': {'uid': '1373cdf7-c5d3-4e8b-bfba-7203e2e1fdb2', 'id': '74612802'},
    '115': {'uid': '5e80ae79-c1a0-4c6a-b37e-8e14d616c608', 'id': '74612803'},
    '116': {'uid': '03951938-1b18-4965-97fa-deffb2092cdd', 'id': '74612804'},
    '117': {'uid': 'f54c1af9-d396-4257-8ee6-ce0036e222d7', 'id': '74612805'},
    '118': {'uid': 'e2afa352-76ca-4f27-93de-d173d1bc09f9', 'id': '74612806'},
    '119': {'uid': '7ce01b7c-ab58-4ab2-aff9-e13363e9a589', 'id': '74612807'},
    '120': {'uid': 'd059087e-dcd7-49c8-8c9c-c8980c5e3ce2', 'id': '74612808'},
    '121': {'uid': '77d11b22-ffda-42c1-9d88-64ab8027194c', 'id': '74612809'},
    '122': {'uid': '3a8ad99f-5a3a-4a06-844e-3d29b3c7ff9b', 'id': '74612811'},
    '123': {'uid': '30536e58-0952-4905-84ed-4144360d9908', 'id': '74612812'},
    '124': {'uid': '76b69dc3-d3fe-4834-9697-91a18af4338c', 'id': '74612813'},
    '125': {'uid': '1c7930f1-5b36-4ba3-8d5c-9d86eec423b3', 'id': '74612814'},
    '126': {'uid': 'c5542aac-84e5-4971-8d08-cf08e45bf59d', 'id': '74612815'},
    '127': {'uid': '531a8b5e-3b93-44be-a37f-4facdf61abc2', 'id': '74612816'},
    '128': {'uid': 'f35365b4-9cdd-4000-bc31-bae36b7496a8', 'id': '74612817'},
    '129': {'uid': 'dca33a97-bff5-4d33-8304-8e918a59da42', 'id': '74612818'},
    '130': {'uid': 'e64e13da-eb4c-4f9b-a345-3039fcdb444b', 'id': '74612819'},
    '131': {'uid': 'f93c3473-5cb5-4814-a358-b0aa56e5a134', 'id': '74612820'},
    '132': {'uid': '407b361d-e661-44db-8854-a3ab702d0340', 'id': '74612821'},
    '133': {'uid': 'b0677bc0-f985-4614-87bb-ddb6cf118e80', 'id': '74612822'},
    '134': {'uid': 'dc02767b-91ee-4aa8-aa66-3aced284c261', 'id': '74612823'},
    '135': {'uid': '13f7ad97-005b-49ed-82ec-60b3db833ec0', 'id': '74612824'},
    '136': {'uid': '0ab1a93f-46b8-4f7b-9c74-b40beb9ba3a7', 'id': '74612825'},
    '137': {'uid': 'e746f227-f5a4-4515-8054-7a5f5924f3ee', 'id': '74612826'},
    '138': {'uid': 'e55fab2b-3f0e-4a77-862b-6f5fff5155d1', 'id': '74612827'},
    '139': {'uid': '405ff118-e1af-4e1a-8078-7f4436cb6cbe', 'id': '74612828'},
    '140': {'uid': '45ae3d9c-2279-4b51-ac81-38a07a70758a', 'id': '74612830'},
    '141': {'uid': 'acf4c347-60ad-4152-8829-a34dc171a81e', 'id': '74612831'},
    '142': {'uid': '56484f8f-d1c7-4f61-8896-1dab53f80e2b', 'id': '74612832'},
    '143': {'uid': '58d3068f-1c41-4f6b-8caf-8f29a05393c3', 'id': '74612833'},
    '144': {'uid': '9c26a861-397c-4b39-94ad-d07fb63da7f5', 'id': '74612834'},
    '145': {'uid': 'b6cec058-814b-4be7-8dfc-a717aed434bb', 'id': '74612835'},
    '146': {'uid': '98d21de7-e572-4b42-a743-9408a9d31285', 'id': '118685824'},
    '147': {'uid': 'f30cb28c-beee-4e98-811e-c461291119b6', 'id': '74612837'},
    '148': {'uid': 'cd6d7379-b0ef-481a-8653-5e2cf018a56f', 'id': '124026882'},
    '149': {'uid': 'a942a6ae-36b8-4478-87bc-32eaa1e7b414', 'id': '74612839'},
    '150': {'uid': '72285e6f-8d4b-4b7f-aa7f-65be1b622c21', 'id': '74612840'},

    'autotest-1': {'uid': '9c2aa947-7356-40e3-87e4-503c3dc253e5', 'id': '65568791'},
    'autotest-2': {'uid': '9c2aa947-7356-40e3-87e4-503c3dc253e5', 'id': '65568792'},
    'autotest-3': {'uid': '9c2aa947-7356-40e3-87e4-503c3dc253e5', 'id': '65568794'},
    'autotest-4': {'uid': '777a014d-8f3d-4a19-8ef9-01b69f38f1d4', 'id': '72876034'},
    'autotest-5': {'uid': '85602683-9c46-470d-b1f0-0bcaa1dadd01', 'id': '76709895'},
    'autotest-6': {'uid': '0514cf4d-dc8d-4a1b-83a8-0244ccd417f4', 'id': '76709896'},
    'autotest-7': {'uid': 'ed6f427e-b35f-4859-b6a9-164cfd5256ce', 'id': '76709898'},
    'autotest-8': {'uid': '28a0ce56-91e2-4608-af3b-b9ee25cdbc06', 'id': '76709899'},
    'autotest-9': {'uid': '8723585c-d74d-49b5-b343-2e3454691ecb', 'id': '76709900'},
    'autotest-10': {'uid': '95abc1c1-9837-4906-b3a1-0e0fedefc131', 'id': '76709901'},
    'autotest-11': {'uid': '75e8cf4a-0fc4-469a-8929-ef8afce2e647', 'id': '76709902'},
    'autotest-12': {'uid': '56257421-060b-444a-9606-36353b9fa443', 'id': '76709903'},
    'autotest-13': {'uid': 'd3aa726e-2de2-41d5-8bb7-9a53863401b1', 'id': '76709904'},
    'autotest-14': {'uid': 'dc5dae04-be8a-485f-8382-0bcd3f623bf8', 'id': '76709905'},
    'autotest-15': {'uid': 'a2c07e64-2c2c-401f-8b87-81b7a7b58fb6', 'id': '76709906'},
    'autotest-16': {'uid': '31379101-596a-4cbc-98cb-c874f7c79fef', 'id': '76709907'},
    'autotest-17': {'uid': '5c7ffe43-f6a7-4d85-9b70-6b8a4238ad25', 'id': '76709908'},
    'autotest-18': {'uid': '70b884d5-0e9b-4bee-95aa-f09567f0736c', 'id': '76709909'},
    'autotest-19': {'uid': '8469c6d7-2a42-4ff3-86d6-c1f3dfb31b32', 'id': '76709910'},
    'autotest-20': {'uid': '3c4978d3-8de3-44a6-a80c-e89a63793546', 'id': '76709911'},
    'autotest-21': {'uid': 'd3c42679-a546-4026-8722-2a86d2b3f507', 'id': '76709912'},
    'autotest-22': {'uid': 'c58d8446-522f-4044-b974-4e31c05e0500', 'id': '78381059'},
    'autotest-23': {'uid': 'a8b16ee3-0bcd-46f5-941e-d790faab028e', 'id': '78381060'},
    'autotest-24': {'uid': 'daa089b9-d425-4b15-9f9a-c7380b62af05', 'id': '78381061'},
    'autotest-25': {'uid': 'ec132b5e-f5fa-4975-a005-8b79d0057828', 'id': '78381062'},
    'autotest-26': {'uid': '205a460b-6044-4b4e-a2a2-0e2dece5e63f', 'id': '78381063'},
    'autotest-27': {'uid': 'c1d369d4-af01-43f3-a18f-1f446f9e30f5', 'id': '78381064'},
    'autotest-28': {'uid': '681f25e1-54cd-4a39-84ad-cd7e8ef342d8', 'id': '78381065'},
    'autotest-29': {'uid': 'c605b86d-087f-443a-8074-dafe7ed73db2', 'id': '78381067'},
    'autotest-30': {'uid': 'ef943cf8-24ce-47d6-bb0e-5d4c936996aa', 'id': '78381068'},
    'autotest-31': {'uid': '6458a41d-9b9c-429c-a22d-ee28906943c9', 'id': '78381069'},
    'autotest-32': {'uid': '8044ff19-5610-4969-a572-d4c996fb7314', 'id': '78381070'},
    'autotest-33': {'uid': 'cf7f78d8-5e06-4a98-9518-6acf677d9797', 'id': '78381071'},
    'autotest-34': {'uid': 'd83ada01-2720-48e8-afec-81f99edc312f', 'id': '78381072'},
    'autotest-35': {'uid': '7b409e22-8276-4ec9-b82c-6a70671eac19', 'id': '78381073'},
    'autotest-36': {'uid': 'b11a22bb-66af-4733-8699-fef5949f2d9f', 'id': '78381074'},
    'autotest-37': {'uid': '5e1fe3c7-4122-46fc-928b-e12ff82fca5e', 'id': '78381075'},
    'autotest-38': {'uid': 'afbca865-510a-4441-8f36-f0e588313272', 'id': '78381076'},
    'autotest-39': {'uid': 'ac42eeb9-f69e-4515-8200-dee52d502fb9', 'id': '78381077'},
    'autotest-40': {'uid': 'a336fe0a-1d43-4ac3-8d24-bff61711ddc7', 'id': '78381078'},
    'autotest-41': {'uid': 'd6ec944e-31e8-4780-966f-fa186246b6a8', 'id': '78381079'},
    'autotest-42': {'uid': '49c79313-06d0-4cfe-8a3f-bd4554f1e0af', 'id': '78381080'},
    'autotest-43': {'uid': 'ce5d85c2-75b0-45d0-830a-c216ca6b956a', 'id': '78381081'},
    'autotest-44': {'uid': 'a689e5fb-a59b-42e2-b9db-07d524ce9bd8', 'id': '78381082'},
    'autotest-45': {'uid': '7aadb557-851d-47f5-9477-1c4b5bbc37f3', 'id': '78381083'},
    'autotest-46': {'uid': '3ffd3cc8-67d9-4808-9540-460bb0b3a89a', 'id': '78381084'},
    'autotest-47': {'uid': '2b8e799b-5db2-499d-b578-2bc09609a32a', 'id': '78381085'},
    'autotest-48': {'uid': 'a0ee9ae9-e70d-43a0-a34e-08d716648d2b', 'id': '78381086'},
    'autotest-49': {'uid': '68bb591e-63f0-46a5-a043-3f81197428c4', 'id': '78381087'},
    'autotest-50': {'uid': '7eb7ca82-3f59-4887-be40-db242dcce896', 'id': '78381088'},

    'prod-1': {'uid': 'fc02cb00-c426-4ad4-bbbf-964b026be23a', 'id': '107806723'},
    'prod-2': {'uid': '031f66fc-b920-43b5-8e1d-757f27307227', 'id': '107806724'},
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
        instance_type = 't3.2xlarge'
        availability_zone = AWS_REGION + 'b'
        ami_id = AWS_CI_AUTOTEST_AMI_ID
        snap_id = AWS_CI_AUTOTEST_SNAP_ID
        snap_size = 30
        spot_duriation = 180
    else:
        instance_type = 't3.xlarge'
        availability_zone = AWS_REGION + 'a'
        # ami prepared by packer
        ami_id = AWS_CI_AMI_ID
        snap_id = AWS_CI_SNAP_ID
        snap_size = 45
        spot_duriation = 180

    r = AWS_CLIENT.request_spot_instances(
        InstanceCount=1,
        BlockDurationMinutes=spot_duriation,
        LaunchSpecification={
            'ImageId': ami_id,
            'InstanceType': instance_type,
            'SubnetId': AWS_SUBNETS[availability_zone],
            'KeyName': 'EPAM-SE',
            'BlockDeviceMappings': [
                {
                    'DeviceName': '/dev/sda1',
                    'Ebs': {
                        'DeleteOnTermination': True,
                        'VolumeType': 'gp3',
                        'VolumeSize': snap_size,
                        'SnapshotId': snap_id
                    }
                }
            ],
            'SecurityGroupIds': [
                'sg-5689343e',
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
    instance_type = 't3.xlarge'
    availability_zone = AWS_REGION + 'a'
    # ami prepared by packer
    ami_id = AWS_CI_AMI_ID
    snap_id = AWS_CI_SNAP_ID
    snap_size = 45

    r = AWS_RESOURCE.create_instances(
        ImageId = ami_id,
        InstanceType = instance_type,
        SubnetId = AWS_SUBNETS[availability_zone],
        KeyName = 'EPAM-SE',
        MaxCount = 1,
        MinCount = 1,
        BlockDeviceMappings = [
            {
                'DeviceName': '/dev/sda1',
                'Ebs': {
                    'DeleteOnTermination': True,
                    'VolumeType': 'gp3',
                    'VolumeSize': snap_size,
                    'SnapshotId': snap_id
                }
            }
        ],
        SecurityGroupIds = [
            'sg-5689343e',
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

yaml_conf = yaml.load(conf)

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
