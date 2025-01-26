import json
import boto3
from datetime import datetime, timedelta
from pprint import pprint

KeySchema = [{
    'AttributeName': 'id',
    'KeyType': 'HASH'
}, {
    'AttributeName': 'stream',
    'KeyType': 'RANGE'
}]
AttributeDefinitions = [{
    'AttributeName': 'id',
    'AttributeType': 'N'
}, {
    'AttributeName': 'stream',
    'AttributeType': 'S'
}]
ProvisionedThroughput = {'ReadCapacityUnits': 1, 'WriteCapacityUnits': 1}


class DynamoTable:
    def __init__(self, tablename, region):
        self.tablename = tablename
        self.client = boto3.client("dynamodb", region_name=region)
        dynamodb = boto3.resource('dynamodb')
        self.table = dynamodb.Table(tablename)

        if not self.__table_exists():
            self.__create_table()

    def __table_exists(self):
        try:
            self.client.describe_table(TableName=self.tablename)
            return True
        except self.client.exceptions.ResourceNotFoundException:
            return False

    def __create_table(self):
        self.client.create_table(TableName=self.tablename,
                                 KeySchema=KeySchema,
                                 AttributeDefinitions=AttributeDefinitions,
                                 ProvisionedThroughput=ProvisionedThroughput)

    def __put_item(self, item):
        self.table.put_item(Item=item)

    def create_item(self, id, stream):
        item = {"id": id, "stream": stream, "msg_sent": True}
        self.__put_item(item)

    def get_item(self, id, stream):
        return self.table.get_item(Key={"id": id, "stream": stream})

    """
    def create_item(self, id):
        now = datetime.now().strftime('%Y-%m-%dT%H:%M:%S.%f%z')
        item = {"id": id, "mtime": now, "sent": True }
        self.__put_item(item)
    
    def get_item(self, id):
        return self.table.get_item(Key={"id": id})

    def __update_item(self, id, expr, attrs):
        return self.table.update_item(Key={"id": id},
                                      UpdateExpression=expr,
                                      ExpressionAttributeValues=attrs,
                                      ReturnValues="ALL_NEW")

    def mark_item_sent(self, id):
        return self.__update_item(id, "set sent = :b", {":b": True})
        
    def update_item_mtime(self, id):
        now = datetime.now().strftime('%Y-%m-%dT%H:%M:%S.%f%z')
        return self.__update_item(id, "set mtime = :n", {":n": now})
    """


if __name__ == "__main__":
    d = DynamoTable("pull_requests_queue", "eu-central-1")
