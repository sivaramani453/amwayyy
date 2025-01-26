from request import Request
from queued import Queued
from completed import Completed
from sqs import Sqs
from in_progress import InProgress

from di import DI
from git import GitClient

import json
import logging

def choose_and_execute_action_controller(body, di):
    if body['action'] == 'queued':
        return Queued(di).process(body)
    else:
        di.logger.info('Not a queued action')

    if body['action'] == 'completed':
        return Completed(di).process(body)
    else:
        di.logger.info('Not an completed action, not a queued action, so must be in progress action.')
        return InProgress(di).process(body)

#Handler for processing, no matter if message from SQS or data directly received from webhook
def lambda_handler(event, context):
    di = DI()

    try:
        try:
            if 'body' in event:
                di.logger.info('Receiving from direct URL invocation')
                body = json.loads(event['body'])
                #di.logger.info(event['body'])

                if Request.validate_signature(event['body'], event['headers']['x-hub-signature'], di.config.git.secret):
                    di.logger.info('Signature has been verified')
                else:
                    di.logger.critical('Signature not verified! Possible break-in attempt.')
                    di.notificator.warning('We have received webhook body with broken signature. Something worth looking at.', body)
                    # And shut your mouth! Not a word you know what it's all about!
                    return Request.returnJson(200, 'Nothing to be done.')

            elif 'Records' in event:
                di.logger.info('Receiving from SQS')
                #critical thing is handling only one record at once, so batch lengt has to be configured to ONE!
                body = json.loads(event['Records'][0]['body'])
                di.logger.info(event['Records'][0]['body'])
                
                #if in Records, then it's received from SQS and signature has been verified. Skip verification.
            else:
                raise Exception('Event does not contain body nor records.')
            
            di.logger.info('Moving forward, exception not triggered...')

        except Exception as e:
            di.logger.critical(str(e))
            di.logger.critical('Received critial when handling body to json conversion. Malformed request body, or missing X-GitHub-Delivery header')
            di.logger.critical(logging.traceback.format_exc())
            di.notificator.critical('We have received malformed or missing webhook body, or missing X-GitHub-Delivery header: ' + str(e), {})
            return Request.returnJson(400, 'Malformed or missing request body, or missing X-GitHub-Delivery header.')

        if 'self-hosted' not in body['workflow_job']['labels']:
            di.logger.info('Not requiring self-hosted, quitting...')
            return Request.returnJson(200, 'Nothing to be done, as we are not working on self-hosted runners.')
        else:
            di.logger.info('This job needs self-hosted runner, carrying on...')

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
    
        response = choose_and_execute_action_controller(body, di)               
        if response['statusCode'] != 200 and 'Records' in event:
            raise Exception(response['body'])
        return response
        
    except Exception as e:
        di.logger.critical(logging.traceback.format_exc())
        if 'body' not in event:
            di.notificator.critical('Something bad happend while spawning worker, we\'re in SQS consumer, raising exception. Reattempt will be made. ' + str(e), body)
            raise e
        else:
            di.notificator.critical('Something bad happend while spawning worker.', body)

#Handler for processing message received via URL request
#For Queued - just verify signature and put it on SQS
#For others - call the proper handler, as only worker spawning has to be queued
def queue_message(event, context):
    di = DI()

    try:
        di.logger.info('Receiving from direct URL invocation')
        body = json.loads(event['body'])
        #di.logger.info(event['body'])

        if Request.validate_signature(event['body'], event['headers']['x-hub-signature'], di.config.git.secret):
            di.logger.info('Signature has been verified')
        else:
            di.logger.critical('Signature not verified! Possible break-in attempt.')
            di.notificator.warning('We have received webhook body with broken signature. Something worth looking at.', body)
            # And shut your mouth! Not a word you know what it's all about!
            return Request.returnJson(200, 'Nothing to be done.')
    except Exception as e:
            di.logger.critical(str(e))
            di.logger.critical('Received critial when handling body to json conversion. Malformed request body, or missing X-GitHub-Delivery header')
            di.logger.critical(logging.traceback.format_exc())
            di.notificator.critical('We have received malformed or missing webhook body, or missing X-GitHub-Delivery header: ' + str(e), {})
            return Request.returnJson(400, 'Malformed or missing request body, or missing X-GitHub-Delivery header.')

    if 'self-hosted' not in body['workflow_job']['labels']:
        di.logger.info('Not requiring self-hosted, quitting...')
        return Request.returnJson(200, 'Nothing to be done, as we are not working on self-hosted runners.')
    else:
        di.logger.info('This job needs self-hosted runner, carrying on...')

    try:
        di.gitClient = lambda: GitClient(
            di,
            body['organization']['login'], #organization
            body['repository']['name'], #repository
            di.config.git.token
        )

        di.logger.addPrefix(body['repository']['name'])
        di.logger.addPrefix(body['workflow_job']['id'])

        if body['action'] == 'queued':
            #By default it sends only queued events to the queue for processing
            response = Sqs(di).process(event['body'])
            if response['statusCode'] != 200:
                di.notificator.message('There was problems while spawning workers.', body)
            # else:
            #     di.notificator.message('Queued action has been sent to SQS for further processing', body)
            return response
        else:
            di.logger.info('Not a queued action')

        if body['action'] == 'completed':
            return Completed(di).process(body)
        else:
            di.logger.info('Not an completed action - must be in progress action...')
            return InProgress(di).process(body)
    except:
        di.logger.critical(logging.traceback.format_exc())
        di.notificator.critical('Something bad happend while spawning worker.', body)

if __name__ == "__main__":
    print(lambda_handler(None, None))

