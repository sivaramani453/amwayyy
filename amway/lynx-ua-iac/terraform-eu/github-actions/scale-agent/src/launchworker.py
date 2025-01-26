import boto3

def create_instances():
	name_tag = [{"Key": "Name", "Value": "QA-worker-manual"},{"Key": "Owner", "Value": "Jan Machalica"},{"Key":"Purpose","Value":"Manual launch due to scaler malfunction"}]

	response = boto3.resource("ec2").create_instances(
		ImageId='ami-07043d7a151cc983d',
		InstanceType='t3a.large',
		KeyName='amway-eu-hybris-dev',
		SecurityGroupIds=['sg-03040dbe268f59fa6'],
		SubnetId='subnet-0723968b9614ea2f0',
		MinCount=3,
		MaxCount=3,
		IamInstanceProfile={"Name":'gh-scale-agent-auto-instance-iam-profile'},
		BlockDeviceMappings=[{
			"DeviceName": "/dev/sda1",
			"Ebs": {
				"DeleteOnTermination": True,
				"VolumeType": "gp2",
				"VolumeSize": 50
			}
		}],
		TagSpecifications=[{
			"ResourceType": "instance",
			"Tags": name_tag
		},{
			"ResourceType": "volume",
			"Tags": name_tag
		}])
	return response
	
	
print(create_instances())