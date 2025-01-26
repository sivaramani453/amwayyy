import boto3
from pprint import pprint


class Cache:
    key = "k"
    value = "v"

    def __init__(self, tablename, region):
        r = boto3.resource('dynamodb', region_name=region)
        self.t = r.Table(tablename)

    def get_item(self, k, defval):
        item = self.t.get_item(Key={self.key: k})

        return item.get("Item", {}).get(self.value, defval)

    def set_item(self, k, v):
        item = {self.key: k, self.value: v}
        self.t.put_item(Item=item)

    def append_item(self, k, *args):
        cur_val = self.get_item(k, [])

        if not isinstance(cur_val, list):
            raise RuntimeError(
                "Cache obj to append is not list. Key: {0}".format(k))

        for v in args:
            cur_val.append(v)

        self.set_item(k, cur_val)

    def remove_item(self, k, *args):
        cur_val = self.get_item(k, [])

        if not isinstance(cur_val, list):
            raise RuntimeError(
                "Cache obj to append is not list. Key: {0}".format(k))

        for v in args:
            try:
                cur_val.remove(v)
            except:
                pass

        self.set_item(k, cur_val)

    def save(self):
        pass
