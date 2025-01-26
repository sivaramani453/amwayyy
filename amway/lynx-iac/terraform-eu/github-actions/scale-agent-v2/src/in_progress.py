from request import Request

class InProgress(Request):
    def process(self, body):
        return Request.returnJson(200, 'Nothing to be done, no-oping')