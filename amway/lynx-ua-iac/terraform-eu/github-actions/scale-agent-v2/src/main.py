from request import Request
from queued import Queued
from completed import Completed
from in_progress import InProgress
from di import DI

import json
import traceback

def lambda_handler(event, context):
    di = DI()

    try:
        try:
            body = json.loads(event['body'])
            di.logger.info('X-GitHub-Delivery header (displayed by GitHub in recent deliveries): ' + event['headers']['X-GitHub-Delivery'])
        except:
            di.logger.critical('Malformed request body, or missing X-GitHub-Delivery header')
            di.notificator.critical('We have received malformed webhook body, or missing X-GitHub-Delivery header', {})
            return Request.returnJson(400, 'Malformed request body, or missing X-GitHub-Delivery header')

        if Request.validate_signature(event['body'], event['headers']['X-Hub-Signature'], di.config.git.secret):
            di.logger.info('Signature has been verified')
        else:
            di.logger.critical('Signature not verified! Possible break-in attempt.')
            di.notificator.warning('We have received webhook body with broken signature. Something worth looking at.', body)
            # And shut your mouth! Not a word you know what it's all about!
            return Request.returnJson(200, 'Nothing to be done.')

        if 'self-hosted' not in body['workflow_job']['labels']:
            return Request.returnJson(200, 'Nothing to be done, as we are not working on self-hosted runners.')

        if body['action'] == 'queued':
            response = Queued(di).process(body)
            if response['statusCode'] != 200:
                di.notificator.message('There was problems while spawning workers.', body)
            return response

        if body['action'] == 'completed':
            return Completed(di).process(body)

        return InProgress(di).process(body)
    
    except:
        di.notificator.critical('Something bad happend whiile spawning worker.', body)
    
if __name__ == "__main__":
    print(lambda_handler(None, None))