import boto3


class AWSInstance(dict):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.__dict__ = self


class AWSClient:
    tags = [{"Key": "Schedule", "Value": "running"}]
    userdata = """#!/bin/bash
                  curl -L {download_url} --output /home/{runner_user}/runner.tar.gz
                  mv /home/{runner_user}/{runner_workdir}/install.sh /tmp
                  rm -rf /home/{runner_user}/{runner_workdir}
                  mkdir -p /home/{runner_user}/{runner_workdir}
                  tar -zxf /home/{runner_user}/runner.tar.gz --directory /home/{runner_user}/{runner_workdir}
                  mv /tmp/install.sh /home/{runner_user}/{runner_workdir}
                  chown -R {runner_user}:{runner_group} /home/{runner_user}/{runner_workdir}
                  """

    def __init__(self, region):
        self.ec2_r = boto3.resource("ec2", region_name=region)
        self.ec2_c = boto3.client("ec2", region_name=region)
        self.ssm_c = boto3.client("ssm", region_name=region)

    def create_instances(self, **kwargs):
        name_tag = [{"Key": "Name", "Value": kwargs.get("name")}]

        response = self.ec2_r.create_instances(
            ImageId=kwargs.get("ami"),
            InstanceType=kwargs.get("type"),
            KeyName=kwargs.get("kp"),
            SecurityGroupIds=[kwargs.get("sg")],
            UserData=self.userdata.format_map(kwargs.get("userdata_vals")),
            SubnetId=kwargs.get("subnet"),
            MinCount=1,
            MaxCount=kwargs.get("count"),
            IamInstanceProfile=kwargs.get("iam_profile"),
            BlockDeviceMappings=[{
                "DeviceName": "/dev/sda1",
                "Ebs": {
                    "DeleteOnTermination": True,
                    "VolumeType": "gp3",
                    "VolumeSize": int(kwargs.get("disk_size"))
                }
            }],
            TagSpecifications=[{
                "ResourceType": "instance",
                "Tags": self.tags + name_tag
            }])
        return [
            AWSInstance(id=i.instance_id, ip=i.private_ip_address)
            for i in response
        ]

    def terminate_instances(self, ids):
        response = self.ec2_c.terminate_instances(InstanceIds=ids)
        return response

    def put_ssm_params(self, id, repo, token):
        repo_key = "actions-repo-{0}".format(id)
        token_key = "actions-token-{0}".format(id)

        # put join token
        self.ssm_c.put_parameter(Name=token_key,
                                 Value=token,
                                 Type="SecureString",
                                 Overwrite=True)
        # put repo
        self.ssm_c.put_parameter(Name=repo_key,
                                 Value=repo,
                                 Type="SecureString",
                                 Overwrite=True)

    def delete_ssm_params(self, id):
        repo_key = "actions-repo-{0}".format(id)
        token_key = "actions-token-{0}".format(id)

        self.ssm_c.delete_parameters(Names=[repo_key, token_key])
