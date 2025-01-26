import boto3

class SSMParameterStore:
    def __init__(self, region):
        self.client = boto3.client("ssm", region_name=region)
   
    def get_ssm_parameter(self, name):
        parameter = self.client.get_parameter(Name=name, WithDecryption=True)['Parameter']

        return parameter['Value']

    def put_ssm_parameter(self, name, value):
        parameter = self.client.put_parameter(Name=name, Value=value, Overwrite=True)
