import abc
import requests


class Notifcator(abc.ABC):
    def __init__(self, **kwargs):
        self.to = kwargs.get("to")
        self.secret = kwargs.get("secret")
        self.url = kwargs.get("url")

    @abc.abstractmethod
    def send_message(self):
        pass


class SkypeNotificator(Notifcator):
    def send_message(self, msg):
        return send_skype_message(self.url, msg, self.to, self.secret)


class TeamsNotificator(Notifcator):
    def send_message(self, msg):
        return send_teams_message(self.url, msg, self.to, self.secret)


class StubNotificator(Notifcator):
    def send_message(self, msg):
        # just a stub
        return 200


def send_skype_message(url, message, chan, secret):
    payload = {
        "channel": chan,
        "secret": secret,
        "type": "simple",
        "text": message
    }
    headers = {"Content-Type": "application/json", "accept-version": "1.0.0"}

    status_code = 0
    try:
        response = requests.post(url, headers=headers, json=payload)
        status_code = response.status_code
    # Not really interested why or where
    # because this is skype who cares
    except:
        pass
    return status_code


def send_teams_message(url, message, chan, secret):
    status_code = 0
    headers = {"Content-Type": "application/json"}
    payload = {"text": message}
    url = url.format(chan=chan, secret=secret)
    try:
        response = requests.post(url, headers=headers, json=payload)
        status_code = response.status_code
    except:
        pass
    return status_code
