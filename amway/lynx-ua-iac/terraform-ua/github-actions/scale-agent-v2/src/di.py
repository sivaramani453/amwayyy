from log import get_global_logger
from config import config
from notificator import TeamsNotificator, ChainNotificator
import boto3

class DI:
    objects = {}
    fabricators = {}
    
    def __init__(self):
        # just define how to produce dependencies
        # provide fabrication method for every dependency that may be needed
        self.fabricators['logger'] = lambda: get_global_logger('main', debug=True)
        self.fabricators['config'] = lambda: config()
        self.fabricators['awsClient'] = lambda: boto3.client('ec2')
        self.fabricators['ssmClient'] = lambda: boto3.client('ssm')
        self.fabricators['notificator'] = self.makeNotificator

    def __getattr__(self, name: str):
        # lazy create dependency instance (when one is not used yet), and return what you got
        if not name in self.objects:
            self.objects[name] = self.fabricators[name]()
        
        return self.objects[name]

    def __setattr__(self, name: str, value) -> None:
        # dynamically provide fabrication method for a named dependency
        self.fabricators[name] = value

    def makeNotificator(self):
        #fabrication method for Notificator, as it would be hard to get it into lambda :D
        notificator = ChainNotificator(self)

        for url in self.config.teams.url.splitlines():
            self.logger.info("Creating Teams notificator for URL " + url)
            notificator.addNotificator(TeamsNotificator(self, url.strip()))

        return notificator