from request import Request
from time import sleep
import boto3

class Completed(Request):
    def delete_ssm_params(self, id):
        repo_key = "actions-repo-{0}".format(id)
        token_key = "actions-token-{0}".format(id)
        type_key = "actions-type-{0}".format(id)
        self.di.logger.debug(self.di.ssmClient.delete_parameters(Names=[repo_key, token_key, type_key]))

    def process(self, body):
        if 'keepalive' not in body['workflow_job']['labels']:
            # the critical thing is to realize how the runners are named
            # we name them simply after AWS instance id
            # so when we receive webhook with runner name, we can simply clean up everything,
            # cos' we know which machine the job is related to.
            try:
                self.delete_ssm_params(body['workflow_job']['runner_name'])
            except Exception as e:
                msg = 'Could not delete SSM params after job is over'
                self.di.logger.critical(str(e))
                return Request.returnJson(500, {'message': msg})

            # might be useful when still working with non-ephemeral runners
            # just kill them when their did their job!
            # might cause problems if some job is waiting for a runner while killing old one
            # cos the runner we're about to kill might be already assigned to new job...
            try:
                sleep(5) #give ephemeral runners some time to deregister
                ec2 = boto3.resource('ec2')
                instance = ec2.Instance(body['workflow_job']['runner_name'])
                instance.terminate()
            except Exception as e:
                self.di.logger.info(e)
                self.di.logger.info('Above is nothing to worry about. You cant terminate instance which is already terminated, right?')

        return Request.returnJson(200, 'I cleaned the things up.')