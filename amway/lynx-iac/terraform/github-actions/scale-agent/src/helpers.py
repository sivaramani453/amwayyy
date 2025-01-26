import re
import time
import logging
import hmac
import hashlib


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


def get_type_by_name(name):
    p = re.compile("\((.+?)\)")
    itypes = p.findall(name.casefold())
    return itypes[0] if itypes else None
