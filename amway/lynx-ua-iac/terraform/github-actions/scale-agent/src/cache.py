import json


class Cache:
    path = None
    data = {}

    def __init__(self, path=None):
        if path:
            self.path = path
            self.data = json.loads(open(path).read())

    def get_item(self, k, defval):
        return self.data.get(k, defval)

    def set_item(self, k, v):
        self.data[k] = v

    def append_item(self, k, *args):
        val = self.data.get(k, [])
        for v in args:
            val.append(v)

        self.data[k] = val[-1000:]

    def save(self):
        if self.path:
            with open(self.path, "w") as f:
                f.write(json.dumps(self.data))
