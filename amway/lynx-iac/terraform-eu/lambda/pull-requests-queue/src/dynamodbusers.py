import boto3

class DynamoTableUsers:
    def __init__(self, tablename, region):
        self.tablename = tablename
        self.client = boto3.client("dynamodb", region_name=region)
        dynamodb = boto3.resource('dynamodb')
        self.table = dynamodb.Table(tablename)

        if not self.__table_exists():
            print(tablename, "Doesn't exist")

    def __table_exists(self):
        try:
            self.client.describe_table(TableName=self.tablename)
            return True
        except self.client.exceptions.ResourceNotFoundException:
            return False

    def get_item(self, ghid):
        return self.table.get_item(Key={"gh-username": ghid, "company": "epam"})
