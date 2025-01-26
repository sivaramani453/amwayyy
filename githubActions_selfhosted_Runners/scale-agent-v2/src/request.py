import json
import hmac
import hashlib

class Request:
    def __init__(self, di):
        self.di = di
        
    def process(self, body):
        pass

    def returnJson(code, body):
        return {
            'isBase64Encoded': False,
            'statusCode': code,
            'headers': {},
            'multiValueHeaders': {},
            'body': json.dumps(body)
        }

    def validate_signature(body, signature_header, secret):
        sha_name, github_signature = signature_header.split('=')
        if sha_name != 'sha1':
            print('ERROR: X-Hub-Signature in payload headers was not sha1=****')
            return False
        
        # Create our own signature
        local_signature = hmac.new(secret.encode('utf-8'), msg=body.encode('utf-8'), digestmod=hashlib.sha1)

        # See if they match
        return hmac.compare_digest(local_signature.hexdigest(), github_signature)