import abc
import requests


class Notifcator(abc.ABC):
    def __init__(self, **kwargs):
        self.url = kwargs.get("url")
        self.dest = kwargs.get("dest")
        self.secret = kwargs.get("secret")

    @abc.abstractmethod
    def send_message(self, msg):
        pass


class SkypeNotificator(Notifcator):
    headers = {"Content-Type": "application/json", "accept-version": "1.0.0"}
    payload = {"type": "simple"}

    def send_message(self, msg):
        self.payload["text"] = msg
        self.payload["channel"] = self.dest
        self.payload["secret"] = self.secret

        try:
            requests.post(self.url, headers=self.headers, json=self.payload)
        except:
            pass


class TeamsNotificator(Notifcator):
    headers = {"Content-Type": "application/json"}
    payload = {}

    def send_message(self, msg):
        self.payload["text"] = msg

        try:
            requests.post(self.url, headers=self.headers, json=self.payload)
        except:
            pass
