from __future__ import print_function
from elasticsearch import Elasticsearch
from datetime import datetime
import base64
import json
import zlib
import os

EL = {
    'index': "aws-docgen-eu-dev",
    'doc_type': "aws-log"
}

ES_HOST = os.getenv('ES_HOST')
ES_PORT = os.getenv('ES_PORT')
ES_PROTOCOL = os.getenv('ES_PROTOCOL')


def lambda_handler(event, context):
    # Attach Elasticsearch
    global EL
    EL["index"] = "aws-docgen-eu-qa"
    el = Elasticsearch([{'host': ES_HOST, 'scheme': ES_PROTOCOL, 'port': ES_PORT, "verify_certs": False}])

    try:
        logs = awslogs_handler(event)
        for log in logs:
            send_entry(el, log)

    except Exception as e:
        # Logs through the parsing the error
        err_message = 'Error parsing the object. Exception: {0}'.format(str(e))
        send_entry(el, err_message)
        raise e


# Handle CloudWatch logs
def awslogs_handler(event):
    # Get logs
    data = zlib.decompress(base64.b64decode(event["awslogs"]["data"]), 16 + zlib.MAX_WBITS)
    logs = json.loads(data)

    logs_list = []
    structured_logs = {}

    # Send lines to Elasticsearch
    for log in sorted(logs["logEvents"], key=lambda x: int(x['id'])):
        if not structured_logs.get("extractedFields") or structured_logs["extractedFields"]["request_id"] != log["extractedFields"]["request_id"]:
            if structured_logs:
                logs_list.append(structured_logs)
            structured_logs = log
            structured_logs["extractedFields"]["event"] = "{}: {}".format(log["extractedFields"]["timestamp"], log["extractedFields"]["event"])
            structured_logs = merge_dicts(structured_logs, {
            "aws": {
                "awslogs": {
                    "logGroup": logs["logGroup"],
                    "logStream": logs["logStream"],
                    "owner": logs["owner"]
                }
            }
            })
            structured_logs.pop("message", None)
        else:
            if log.get("extractedFields") and log.get("extractedFields").get("event"):
                structured_logs["extractedFields"]["event"] += "\n{}: {}".format(log["extractedFields"].get("timestamp"), log["extractedFields"]["event"])
    
    logs_list.append(structured_logs)
    return logs_list


def send_entry(el, log_entry):
    # The log_entry can only be a string or a dict
    if isinstance(log_entry, str):
        log_entry = {"message": log_entry}
    elif not isinstance(log_entry, dict):
        raise Exception(
            "Cannot send the entry as it must be either a string or a dict. Provided entry: " + str(log_entry))

    # Send to Elasticsearch
    bucket_name = log_entry.get('aws', {}).get('awslogs', {}).get('logGroup', "")
    if bucket_name == r'/aws/lambda/DocumentGeneratorEuDev':
        EL['index'] = "aws-docgen-eu-dev"
    elif bucket_name == r'/aws/lambda/DocGenEuTestEnv':
        EL['index'] = "aws-docgen-eu-test"
    elif bucket_name == r'/aws/lambda/DecGen':
        EL['index'] = "aws-docgen-eu-dev"       
    
    str_entry = json.dumps(log_entry)
    el.index(body=str_entry, **EL)


def merge_dicts(a, b, path=None):
    if path is None: path = []
    for key in b:
        if key in a:
            if isinstance(a[key], dict) and isinstance(b[key], dict):
                merge_dicts(a[key], b[key], path + [str(key)])
            elif a[key] == b[key]:
                pass  # same leaf value
            else:
                raise Exception(
                    'Conflict while merging metadatas and the log entry at %s' % '.'.join(path + [str(key)]))
        else:
            a[key] = b[key]
    return a
