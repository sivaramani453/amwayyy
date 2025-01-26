import pymsteams

class Notificator:
    def __init__(self, di):
        self.di = di

    def message(self, body, actionBody):
        pass

    def warning(self, body, actionBody):
        pass

    def error(self, body, actionBody):
        pass

    def critical(self, body, actionBody):
        pass

# IE when you'd like to pass couple urls for Teams to send notifications to
# you can create chainNotificator, add TeamsNotificators you create from cfg
# and then register ChainNotificator in di[notificator]
# or you'd like to have another notification channel, like Skype or SMS
# just use as much as you need
class ChainNotificator(Notificator):
    def __init__(self, di):
        self.di = di
        self.notificators = set()

    def addNotificator(self, newone: Notificator):
        self.notificators.add(newone)

    def message(self, body, actionBody):
        for notificator in self.notificators:
            notificator.message(body, actionBody)
    
    def warning(self, body, actionBody):
        for notificator in self.notificators:
            notificator.warning(body, actionBody)

    def error(self, body, actionBody):
        for notificator in self.notificators:
            notificator.error(body, actionBody)

    def critical(self, body, actionBody):
        for notificator in self.notificators:
            notificator.critical(body, actionBody)

class TeamsNotificator(Notificator):
    def __init__(self, di, url):
        self.url = url

    def sendMessage(self, title, body, color, actionBody):
        my_teams_message= pymsteams.connectorcard(self.url)
        my_teams_message.title(title + ' | run ID: ' + str(actionBody['workflow_job']['run_id']) + ' | repo: ' + actionBody['repository']['name'])
        my_teams_message.text(body)
        my_teams_message.color(color)
        try:
            # in case webhook body is malformed and we have no such key in dict like html_url
            my_teams_message.addLinkButton('Open workflow on GitHub', actionBody['workflow_job']['html_url'])
        except:
            pass
        my_teams_message.send()

    def message(self, body, actionBody):
        return self.sendMessage(f'Message from GitHub/AWS scaler', body, '#006400', actionBody)

    def warning(self, body, actionBody):
        return self.sendMessage(f'Warning from GitHub/AWS scaler', '<strong>' + body + '</strong>', '#FFFF00', actionBody)

    def error(self, body, actionBody):
        return self.sendMessage(f'Error from GitHub/AWS scaler', '<strong>' + body + '</strong>', '#FFA500', actionBody)

    def critical(self, body, actionBody):
        return self.sendMessage(f'Critical from GitHub/AWS scaler','<strong>' + body + '</strong>', '#FF0000', actionBody)