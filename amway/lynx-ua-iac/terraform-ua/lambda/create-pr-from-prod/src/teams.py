import requests


def send_teams_message(url, msg):
    payload = {"text": msg}
    headers = {"Content-Type": "application/json"}
    try:
        response = requests.post(url, headers=headers, json=payload)
    except Exception as e:
        print("Could not send Microsoft Teams meessage: {err}".format(err=e))
        return
    if response.status_code != 200:
        print("Microsoft Teams webhook status code is not 200: {code} - {msg}".
              format(code=response.status_code, msg=response.text))
