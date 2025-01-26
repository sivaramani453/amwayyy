from request import Request
from queued import Queued
from completed import Completed
from in_progress import InProgress

from di import DI
from git import GitClient

import json
import logging

def lambda_handler(event, context):
    di = DI()

    try:
        try:
            body = json.loads(event['body'])
            #di.logger.info('1X-GitHub-Delivery header (displayed by GitHub in recent deliveries): ' + event['headers']['X-Github-Delivery'])
            di.logger.info('2X-GitHub-Delivery header (displayed by GitHub in recent deliveries): ' + event['headers']['x-github-delivery'])
        except Exception as e:
            if 'body' in event:
                di.logger.critical(type(event['body']))
            else:
                di.logger.critical('Event object does not contain body.')
            di.logger.critical('Received critial when handling body to json conversion')
            di.logger.critical('Malformed request body, or missing X-GitHub-Delivery header')
            di.logger.critical(logging.traceback.format_exc())
            di.notificator.critical('We have received malformed or missing webhook body, or missing X-GitHub-Delivery header: ' + str(e), {})
            return Request.returnJson(400, 'Malformed or missing request body, or missing X-GitHub-Delivery header.')

        if Request.validate_signature(event['body'], event['headers']['x-hub-signature'], di.config.git.secret):
            di.logger.info('Signature has been verified')
        else:
            di.logger.critical('Signature not verified! Possible break-in attempt.')
            di.notificator.warning('We have received webhook body with broken signature. Something worth looking at.', body)
            # And shut your mouth! Not a word you know what it's all about!
            return Request.returnJson(200, 'Nothing to be done.')

        if 'self-hosted' not in body['workflow_job']['labels']:
            return Request.returnJson(200, 'Nothing to be done, as we are not working on self-hosted runners.')

        #at this stage we know we may need this
        #we take org and repo straight from the request body
        #token stored in config
        di.gitClient = lambda: GitClient(
            di,
            body['organization']['login'], #organization
            body['repository']['name'], #repository
            di.config.git.token
        )

        di.logger.addPrefix(body['repository']['name'])
        di.logger.addPrefix(body['workflow_job']['id'])

        if body['action'] == 'queued':
            response = Queued(di).process(body)
            if response['statusCode'] != 200:
                di.notificator.message('There was problems while spawning workers.', body)
            return response

        if body['action'] == 'completed':
            return Completed(di).process(body)

        return InProgress(di).process(body)
    
    except:
        di.logger.critical(logging.traceback.format_exc())
        di.notificator.critical('Something bad happend while spawning worker.', body)
    
if __name__ == "__main__":
    print(lambda_handler(None, None))