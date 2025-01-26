from request import Request

class Sqs(Request):
    def process(self, body):
        self.di.logger.info('Target queue is ' + self.di.config.aws.sqs_target)
        sqs = self.di.sqsResource.get_queue_by_name(QueueName=self.di.config.aws.sqs_target)
        self.di.logger.info('Sending the message')
        response = sqs.send_message(MessageBody=body)
        return Request.returnJson(200, {'message': 'This request has been placed in SQS queue and will be handled soon.'})