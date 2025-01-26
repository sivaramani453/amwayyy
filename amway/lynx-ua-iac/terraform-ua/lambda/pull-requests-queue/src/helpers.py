import time
import requests
import logging
from datetime import datetime, timedelta

# Const
QUEUE_LABEL_URGENT = "add to queue urgent"


class TimeoutError(Exception):
    pass


def repeat(times):
    def inner(func):
        def wrapper(*args, **kwargs):
            error_message = ""
            for i in range(1, times + 1):
                try:
                    result = func(*args, **kwargs)
                    return result
                except Exception as err:
                    error_message = err.__str__()
                    if i != times:
                        time.sleep(7)
            raise TimeoutError(
                "Function {0} did not succeed in {1} attempts. Last msg is {2}"
                .format(func.__name__, times, error_message))

        return wrapper

    return inner


def sort_pr_based_on_label(pr):
    labels = {x.name: True for x in pr.labels}
    delta = 25 if labels.get(QUEUE_LABEL_URGENT) else 0

    return pr.updated_at - timedelta(days=365 * delta)


def get_debug_string(pr):
    msg = "Processing pull requst {url} from {head} to {base} with labels {labels}; with review state {review}; with mergeable_state {m_state}; with combined_status {c_state}; with statuses {statuses}; created by {login}".format(
        url=pr.url,
        head=pr.head,
        base=pr.base,
        login=pr.login,
        review=pr.approved,
        m_state=pr.mergeable_state,
        c_state=pr.combined_state,
        labels=", ".join([k for k in pr.labels]),
        statuses=", ".join(pr.statuses))
    return msg
