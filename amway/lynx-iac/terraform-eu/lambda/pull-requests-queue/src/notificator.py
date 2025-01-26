import abc
import requests
import json
from string import Template

x = """{
    "type":"message",
    "attachments":[
       {
          "contentType":"application/vnd.microsoft.card.adaptive",
          "content":{
             "$schema":"http://adaptivecards.io/schemas/adaptive-card.json",
             "type":"AdaptiveCard",
             "version":"1.2",
             "msteams": {
                "width": "Full",
                "type": "messageBack",
                "entities": [
                  {
                    "type": "mention",
                    "text": "<at>${username}</at>",
                    "mentioned": {
                      "id": "${email}",
                      "name": "${username}"
                    }
                  }
                ]
              },
             "body": [
                {
                  "type": "TextBlock",
                  "width": "Full",
                  "text": "<at>${username}</at>",
                  "weight": "bolder"
                },
                {
                  "type": "TextBlock",
                  "width": "Full",
                  "text": "${massage}",
                  "wrap": "true"
                }
              ]
          }
       }
    ]
}
"""

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
    def __init__(self, **kwargs):
        self.to = kwargs.get("to")
        self.secret = kwargs.get("secret")
        self.url = kwargs.get("url")
        self.dynamoTableUsers = kwargs.get("dynamoTableUsers")

    def send_message_tag(self, msg, ghid):
        userdataResolved = self.dynamoTableUsers.get_item(ghid)
        # print(userdataResolved)
        if userdataResolved.get("Item", {}):
            email = userdataResolved["Item"]["email"]
            username = userdataResolved["Item"]["user"]
            return send_teams_tags_message(self.url, msg, self.to, self.secret, email , username)
        else:
            print(ghid, "User not found in dynamoDB")
            email = ghid
            username = ghid
            return send_teams_tags_message(self.url, msg, self.to, self.secret, email , username)
        
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

def send_teams_tags_message(url, msg, chan, secret, email, username):
    configuration, headers = ({}, {})
 
    headers["Content-Type"] = "application/json"
    headers["accept-version"] = "1.0.0"
    webhook_endpoint = url.format(chan=chan, secret=secret)

    data = dict(
        massage = msg, 
        email = email,
        username = username,
        schema = "$schema"
    )

    template = Template(x)
    configuration = json.loads(template.substitute(data))

    # print(configuration)

    response = requests.post(webhook_endpoint, headers=headers, json=configuration)
    return response.status_code
