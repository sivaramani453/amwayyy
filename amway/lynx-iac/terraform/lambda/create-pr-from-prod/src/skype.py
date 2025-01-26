import requests


def send_skype_message(url, secret, channel, msg):
    payload = {
        "channel": channel,
        "secret": secret,
        "type": "simple",
        "text": msg
    }
    headers = {"Content-Type": "application/json", "accept-version": "1.0.0"}
    try:
        response = requests.post(url, headers=headers, json=payload)
    except Exception as e:
        print("Could not send skype meessage: {err}".format(err=e))
        return
    if response.status_code != 200:
        print("Skype webhook status code is not 200: {code} - {msg}".format(
            code=response.status_code, msg=response.text))
