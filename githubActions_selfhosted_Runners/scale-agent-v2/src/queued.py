from botocore.exceptions import CapacityNotAvailableError, ClientError
from request import Request
import re
import traceback
import logging
import time
import random

tags = [
            {
            'Key': 'ApplicationID',
            'Value': 'APP1433689'
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

instance_tags = [
            {
            'Key': 'Schedule',
            'Value': 'running'
            },
            {
            'Key': 'DataClassification',
            'Value': 'Internal'
            },
            {
            'Key': 'SEC-INFRA-13',
            'Value': 'Appliance'
            },
            {
            'Key': 'SEC-INFRA-14',
            'Value': 'Latest90days'
            },
            {
            'Key': 'ITAM-SAM',
            'Value': 'Appliance'            
            }
]

userdata = """#!/bin/bash
                curl -L {download_url} --output /home/{runner_user}/runner.tar.gz
                mv /home/{runner_user}/{runner_workdir}/install.sh /tmp
                rm -rf /home/{runner_user}/{runner_workdir}
                mkdir -p /home/{runner_user}/{runner_workdir}
                tar -zxf /home/{runner_user}/runner.tar.gz --directory /home/{runner_user}/{runner_workdir}
                mv /tmp/install.sh /home/{runner_user}/{runner_workdir}
                chown -R {runner_user}:{runner_group} /home/{runner_user}/{runner_workdir}
                """
# instance types we can choose our spots from
# ordering is important, it starts from the cheapest Intel,
# then goes to the same shape for amd,
# then goes better Intel, corresponding AMD, and so on
#
# In algorithm we start from the configured instance,
# and if it's unavailable we go to the higher alternative
# simply by selecting next row from this array
#
# Prices needs to be set as failover prices, ie request shall not be rejected due to low price
instance_types = [
    {'type': 't3.small',    'max_price': '0.01'},
    {'type': 't3a.small',   'max_price': '0.01'},
    {'type': 't3.medium',   'max_price': '0.01'},
    {'type': 't3a.medium',  'max_price': '0.01'},
    {'type': 't3.large',    'max_price': '0.01'},
    {'type': 't3a.large',   'max_price': '0.015'},
    {'type': 't3.xlarge',   'max_price': '0.015'},
    {'type': 't3a.xlarge',  'max_price': '0.015'},
    {'type': 't3.2xlarge',  'max_price': '0.017'},
    {'type': 't3a.2xlarge', 'max_price': '0.017'},
    ]

class Queued(Request):

    def process(self, body):
        self.di.logger.info("Attempting to launch spot instance - action queued")
        # workflow_job run is in address of job run in github                          ##########
        # https://github.com/AmwayACS/microservice-address-validation-ua/actions/runs/2415739518
        # that's how we can quickly identify runner for given GH job and GH job for a given runner
        #
        # while run_id is for overall workflow execution, less specific
        name_tag = [{"Key": "Name", "Value": "github-actions-runner-v2-" + body['repository']['name'] + "--" + str(body['workflow_job']['id'])}]

        job_workflow_tags = [
            {"Key": "Job", "Value": str(body['workflow_job']['id'])},
            {"Key": "Workflow", "Value": str(body['workflow_job']['run_id'])},
            {"Key": "html_url", "Value": str(body['workflow_job']['html_url'])},
            {"Key": "Repository", "Value": body['repository']['name']}
        ]

        try:
            self.di.logger.info("Check runner package url...")
            download_url = self.di.gitClient.get_runner_package_url()
            self.di.logger.debug("Found runner package url: {0}".format(download_url))

            userdata_vals = {
                "runner_user": self.di.config.runner.user,
                "runner_group": self.di.config.runner.group,
                "runner_workdir": self.di.config.runner.workdir,
                "download_url": download_url
            }

        except Exception as e:
            msg = "Could not get github runner download url: {0}".format(e)
            self.di.logger.critical(logging.traceback.format_exc())
            self.di.logger.critical(msg)
            return Request.returnJson(500, {'message': msg})

        try:
            join_token = ''
            join_token = self.di.gitClient.get_runner_join_token()
        except Exception as e:
            self.di.logger.critical('Unable to obtain join token for runner')
            self.di.logger.error(traceback.format_exc())
            return Request.returnJson(500, {'message': 'Unable to obtain join token for runner'})

        self.di.logger.info("Join token were obtained in github: " + join_token)

        # following line distributes load when multiple runners are being spawned same second
        time.sleep(random.randint(0,20))

        try:
            self.di.logger.info('Attempting to request spot instance...')
            if 'critical' in body['workflow_job']['labels'] or self.di.config.aws.ondemand == '1':
                raise Exception('Using spots has been disabled by job label or lambda config variable...')
            requestResult = self.requestSpotInstance(userdata_vals, name_tag, job_workflow_tags, body)
            response = requestResult['Response']
            typeReceived = requestResult['RequestedType']

        except Exception as e:
            self.di.logger.error(traceback.format_exc())
            self.di.logger.error(e)
            self.di.logger.error('Attempting to request ondemand, as we are missing spot capacity.')
            try:
                requestResult = self.requestOndemandInstance(userdata_vals, name_tag, job_workflow_tags, body)
                response = requestResult['Response']
                typeReceived = requestResult['RequestedType']
            except Exception as e:
                self.di.logger.error(traceback.format_exc())
                self.di.logger.error(e)
                return Request.returnJson(500, {'message': 'Unable to request instance.'})

# I need to fetch spot request object 1st, and only then use its create_tags method

        # try:
        #     self.di.awsClient.create_tags(response["Instances"][0]["SpotInstanceRequestId"], tags + name_tag + job_workflow_tags)
        # except Exception as e:
        #     self.di.logger.error('Non-critical exception, unable to tag spot requests.')
        #     self.di.logger.error(e)
        #     self.di.logger.error(traceback.format_exc())
        #     self.di.logger.error(response["Instances"][0])
        #     print(e)

        instanceId = response["Instances"][0]["InstanceId"]
        self.di.logger.info(response["Instances"][0]["InstanceId"])

        full_repo_name = "{0}/{1}".format(body['organization']['login'], body['repository']['name'])
        self.di.logger.info('Putting GH worker join information in SSM for a just started host')
        try:
            self.put_ssm_params(instanceId, full_repo_name, join_token, body['workflow_job']['labels'])
        except Exception as e:
            self.di.logger.critical('Unable to store token for a runner')
            self.di.logger.error(traceback.format_exc())
            return Request.returnJson(500, {'message': 'Unable to store token for a runner'})

        self.di.logger.info('Seems that everything went just fine')

        return Request.returnJson(200, {'message': 'Worker should be booting right now: ' + instanceId,
                                        'repo': full_repo_name,
                                        'type': typeReceived, 
                                        'token': "{0}***{1}".format(
                    join_token[:3], join_token[-3:])})

    def requestSpotInstance(self, userdata_vals, name_tag, job_workflow_tags, body):
        #recognize which instance type we'd like to use. Tagging got higher priority than config
        wanted_instance_type = self.di.config.aws.instance_type
        known_instance_types = set()

        for item in instance_types:
            known_instance_types.add(item['type'])

        tagged_instance_type = set(body['workflow_job']['labels']).intersection(known_instance_types)
        
        if len(tagged_instance_type) > 1:
            raise Exception('Tagging for a workflow gives more than one instance type: ' + str(tagged_instance_type))

        if len(tagged_instance_type) == 1:
            wanted_instance_type = list(tagged_instance_type)[0]

        # if len(tagged_instance_type) == 0:
        #     not tagged at all or we need to fill known_instance_types with new entry, 
        #     but we cannot decide it here. Using configured instance.

        # detect index of the instance type we start with
        starting_type_index = -1

        for index, item in enumerate(instance_types):
            if item['type'] == wanted_instance_type:
                starting_type_index = index

        # either mistake in config entries or allowed instance list is incomplete
        if starting_type_index < 0:
            raise Exception('Requested instance type not found in list of instance types available.') 

        # update price with one received from cfg, we leave other prices intact,
        # as we update configured price leaving failover-prices as-they-are
        instance_types[starting_type_index]['max_price'] = self.di.config.aws.maxprice


        # And now how the loop structure looks like
        # for-looping on instance types:
        #       try:
        #           while-looping until price is lower than 1
        #               try:
        #                   launch attempt
        #               except price too low ONLY!:
        #                   log everything
        #                   increase spot price and re-loop while
        #       except Insufficient capacity ONLY!:
        #           Log everything
        #           re-loop for with next instance type

        for index, current_type in enumerate(instance_types[starting_type_index:]):
            self.di.logger.info('Attempting ' + str(current_type))

            try:
                current_maxprice = float(current_type['max_price'])
                
                while current_maxprice < 1:
                    random.seed()
                    self.di.logger.info('Current max_price is: ' + str(current_maxprice))
                    exceptionCaught = ''
                    try:
                        response = self.di.awsClient.run_instances(
                                MaxCount = 1,
                                MinCount = 1,
                                ImageId = self.di.config.aws.ami,
                                KeyName = self.di.config.aws.kp,
                                SecurityGroupIds = [self.di.config.aws.sg],
                                InstanceType = current_type['type'],
                                UserData=userdata.format_map(userdata_vals),
                                InstanceMarketOptions={
                                    'MarketType': 'spot',
                                    'SpotOptions': {
                                        'MaxPrice': str(current_maxprice),
                                        # 'BlockDurationMinutes': config.aws.duration,
                                        'SpotInstanceType': 'one-time',
                                        'InstanceInterruptionBehavior': 'terminate'
                                    }
                                },
                                BlockDeviceMappings=[{
                                    "DeviceName": "/dev/sda1",
                                    "Ebs": {
                                        "DeleteOnTermination": True,
                                        # Deleting on termination is critical for our needs
                                        # i. e. we don't need to clean ephemeral runners
                                        # when they're not needed anymore
                                        "VolumeType": "gp2",
                                        "VolumeSize": self.di.config.aws.disk_size
                                    }
                                }],
                                EbsOptimized =  True,
                                #We have three subnets available - let's choose one randomly
                                #If we use one, we'll quickly run out of IP addresses for all runners
                                #This will also work for single subnet in cfg
                                SubnetId = random.choice(self.di.config.aws.subnet.splitlines()).strip(),
                                IamInstanceProfile = self.di.config.aws.iam_profile,
                                TagSpecifications=[{
                                    "ResourceType": "instance",
                                    "Tags": tags + instance_tags + name_tag + job_workflow_tags
                                },{
                                    "ResourceType": "volume",
                                    "Tags": tags + instance_tags + name_tag + job_workflow_tags
                                }]
                            )

                        # IMPORTANT:
                        # We return type that was requested, not what we provide
                        # Reason: GitHub labelling will ask for a certain label
                        # and if we provide anything better, GH will not schedule job for it
                        # if labelled with actual type, not requested one

                        return {
                            'Response': response,
                            'RequestedType': wanted_instance_type
                        }

                    except ClientError as e:
                        exceptionCaught = e
                        self.di.logger.info(str(e.response))
                        if e.response['Error']['Code'] == 'SpotMaxPriceTooLow':
                            self.di.logger.warning('Unable to request spot instance type ' 
                            + current_type['type'] + ' due to spot price too low, retrying with better price...')

                            matched = re.search("fulfillment price of (\\d.\\d*).", str(e))
                            if matched:
                                # just pay them what they want
                                current_maxprice = float(matched.group(1)) * 1.3
                            else:
                                # PANIK!!!
                                current_maxprice = str(current_maxprice + 0.01 + (1 - current_maxprice) / 2)

                            # and try current type with better price in the loop
                        elif e.response['Error']['Code'] == 'RequestLimitExceeded':
                            #We triggered too many AWS API requests, so we need to slow down RIGHT NOW
                            #Just wait couple seconds and retry
                            time.sleep(10)
                        else:
                            # Might be anything, including Insufficient Capacity, but we can't handle it here
                            # just end with this type of instance and pass to for-loop error handling
                            raise e

            except ClientError as e:
                exceptionCaught = e
                if e.response['Error']['Code'] == 'InsufficientInstanceCapacity':
                    self.di.logger.warning('Unable to request spot instance type ' 
                    + current_type['type'] + ' due to insufficient capacity, trying next available type (if any)...')
                    # and try next type in the loop
                else:
                    raise e
            #don't handle other exceptions over here
            
            #self.di.notificator.warning('I was unable to obtain requested spot instance ' + current_type['type'] + ' due to: ' + str(exceptionCaught) + ', retrying with better one if possible...', body)
        
        raise Exception('Unable to request spot instance of any known type')

    def requestOndemandInstance(self, userdata_vals, name_tag, job_workflow_tags, body):
         #recognize which instance type we'd like to use. Tagging got higher priority than config
        wanted_instance_type = self.di.config.aws.instance_type
        known_instance_types = set()

        for item in instance_types:
            known_instance_types.add(item['type'])

        tagged_instance_type = set(body['workflow_job']['labels']).intersection(known_instance_types)
        
        if len(tagged_instance_type) > 1:
            raise Exception('Tagging for a workflow gives more than one instance type: ' + str(tagged_instance_type))

        if len(tagged_instance_type) == 1:
            wanted_instance_type = list(tagged_instance_type)[0]

        # if len(tagged_instance_type) == 0:
        #     not tagged at all or we need to fill known_instance_types with new entry, 
        #     but we cannot decide it here. Using configured instance.

        # detect index of the instance type we start with
        starting_type_index = -1

        for index, item in enumerate(instance_types):
            if item['type'] == wanted_instance_type:
                starting_type_index = index

        # either mistake in config entries or allowed instance list is incomplete
        if starting_type_index < 0:
            raise Exception('Requested instance type not found in list of instance types available.') 

        # And now how the loop structure looks like
        # for-looping on instance types:
        #       try:
        #           while-looping until price is lower than 1
        #               try:
        #                   launch attempt
        #               except price too low ONLY!:
        #                   log everything
        #                   increase spot price and re-loop while
        #       except Insufficient capacity ONLY!:
        #           Log everything
        #           re-loop for with next instance type

        for index, current_type in enumerate(instance_types[starting_type_index:]):
            self.di.logger.info('Attempting ' + str(current_type))
            random.seed()
            
            try:                    
                response = self.di.awsClient.run_instances(
                    MaxCount = 1,
                    MinCount = 1,
                    ImageId = self.di.config.aws.ami,
                    KeyName = self.di.config.aws.kp,
                    SecurityGroupIds = [self.di.config.aws.sg],
                    InstanceType = wanted_instance_type,
                    UserData=userdata.format_map(userdata_vals),
                    BlockDeviceMappings=[{
                        "DeviceName": "/dev/sda1",
                        "Ebs": {
                            "DeleteOnTermination": True,
                            # Deleting on termination is critical for our needs
                            # i. e. we don't need to clean ephemeral runners
                            # when they're not needed anymore
                            "VolumeType": "gp2",
                            "VolumeSize": self.di.config.aws.disk_size
                        }
                    }],
                    EbsOptimized =  True,
                    #We have three subnets available - let's choose one randomly
                    #If we use one, we'll quickly run out of IP addresses for all runners
                    #This will also work for single subnet in cfg
                    SubnetId = random.choice(self.di.config.aws.subnet.splitlines()).strip(),
                    IamInstanceProfile = self.di.config.aws.iam_profile,
                    TagSpecifications=[
                        {
                        "ResourceType": "instance",
                        "Tags": tags + instance_tags + name_tag + job_workflow_tags
                        },{
                            "ResourceType": "volume",
                            "Tags": tags + instance_tags + name_tag + job_workflow_tags
                        }
                    ]
                )

                # IMPORTANT:
                # We return type that was requested, not what we provide
                # Reason: GitHub labelling will ask for a certain label
                # and if we provide anything better, GH will not schedule job for it
                # if labelled with actual type, not requested one

                return {
                    'Response': response,
                    'RequestedType': wanted_instance_type
                }

            except ClientError as e:
                self.di.logger.info(str(e.response))
                if e.response['Error']['Code'] == 'RequestLimitExceeded':
                    #We triggered too many AWS API requests, so we need to slow down RIGHT NOW
                    #Just wait couple seconds and retry
                    time.sleep(10)
                elif e.response['Error']['Code'] == 'InsufficientInstanceCapacity':
                    self.di.logger.warning('Unable to request ondemand instance type ' 
                    + current_type['type'] + ' due to insufficient capacity, trying next available type (if any)...')
                    # and try next type in the loop
                else:
                    # Might be anything, including Insufficient Capacity, but we can't handle it here
                    # just end with this type of instance and pass to for-loop error handling
                    raise e
                
                #don't handle other exceptions over here

            self.di.notificator.warning('I was unable to obtain requested ondemand instance, retrying with better one if possible...', body)
        
        raise Exception('Unable to request ondemand instance of any known type')

        #recognize which instance type we'd like to use. Tagging got higher priority than config
        wanted_instance_type = self.di.config.aws.instance_type
        known_instance_types = set()

        for item in instance_types:
            known_instance_types.add(item['type'])

        tagged_instance_type = set(body['workflow_job']['labels']).intersection(known_instance_types)
        
        if len(tagged_instance_type) > 1:
            raise Exception('Tagging for a workflow gives more than one instance type: ' + str(tagged_instance_type))

        if len(tagged_instance_type) == 1:
            wanted_instance_type = list(tagged_instance_type)[0]
        name_tag = [{"Key": "Name", "Value": name_tag}]

        random.seed()
        response = self.di.awsClient.run_instances(
            MaxCount = 1,
            MinCount = 1,
            ImageId = self.di.config.aws.ami,
            KeyName = self.di.config.aws.kp,
            SecurityGroupIds = [self.di.config.aws.sg],
            InstanceType = wanted_instance_type,
            UserData=userdata.format_map(userdata_vals),
            BlockDeviceMappings=[{
                "DeviceName": "/dev/sda1",
                "Ebs": {
                    "DeleteOnTermination": True,
                    # Deleting on termination is critical for our needs
                    # i. e. we don't need to clean ephemeral runners
                    # when they're not needed anymore
                    "VolumeType": "gp2",
                    "VolumeSize": self.di.config.aws.disk_size
                }
            }],
            EbsOptimized =  True,
            #We have three subnets available - let's choose one randomly
            #If we use one, we'll quickly run out of IP addresses for all runners
            #This will also work for single subnet in cfg
            SubnetId = random.choice(self.di.config.aws.subnet.splitlines()).strip(),
            IamInstanceProfile = self.di.config.aws.iam_profile,
            # @TODO
            # problem with parameter validation for tags, list instead of str
            # TagSpecifications=[{
            #     "ResourceType": "instance",
            #     "Tags": name_tag# + tags + instance_tags + job_workflow_tags
            # }
            # ,{
            #      "ResourceType": "volume",
            #      "Tags": name_tag# + tags + instance_tags + job_workflow_tags
            # }
            # ]
        )

        return {
            'Response': response,
            'RequestedType': wanted_instance_type
        }

                        
    def put_ssm_params(self, id, repo, token, labels):
        self.di.logger.info("SSM params for " + id + ": repo: " + repo + ", token: " + token + ", labels: " + ', '.join(labels))
        repo_key = "actions-repo-{0}".format(id)
        token_key = "actions-token-{0}".format(id)
        type_key = "actions-type-{0}".format(id)

        # put join token
        self.di.ssmClient.put_parameter(Name=token_key,
                                    Value=token,
                                    Type="SecureString",
                                    Overwrite=True)
        # put repo
        self.di.ssmClient.put_parameter(Name=repo_key,
                                    Value=repo,
                                    Type="SecureString",
                                    Overwrite=True)

        # put type
        self.di.ssmClient.put_parameter(Name=type_key,
                                    Value=','.join(labels),
                                    Type="SecureString",
                                    Overwrite=True)