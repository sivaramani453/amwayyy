import logging
from time import sleep


# Delay is used to order logs by timestamp in ELK
# beacuse a lot of log messages have the same timestamp down to milliseconds
# so this tricky delay will split logs and order will restore in universe
# and there will be no more wars and children will play
class DelayLogger:
    def __init__(self, logger):
        self.l = logger

    def debug(self, msg):
        sleep(0.01)
        self.l.debug(msg)

    def info(self, msg):
        sleep(0.01)
        self.l.info(msg)

    def warning(self, msg):
        sleep(0.01)
        self.l.warning(msg)

    def error(self, msg):
        sleep(0.01)
        self.l.error(msg)

    def critical(self, msg):
        sleep(0.01)
        self.l.critical(msg)


def get_global_logger(name, debug=False):
    logger = logging.getLogger(name)
    # check if already created
    if len(logger.handlers) > 0:
        # means handlers exists
        # so just return ready to log logger
        return logger
    # Seems that it is first time
    # create handlers etc
    level = logging.DEBUG if debug else logging.INFO
    logger.setLevel(level)
    ch = logging.StreamHandler()
    formatter = logging.Formatter(
        '%(asctime)s.%(msecs)03d %(levelname)s %(message)s',
        "%Y-%m-%dT%H:%M:%S")
    ch.setFormatter(formatter)
    logger.addHandler(ch)
    custom_logger = DelayLogger(logger)
    return custom_logger
