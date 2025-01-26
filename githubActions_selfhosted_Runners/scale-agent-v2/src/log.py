import logging
from time import sleep


# Delay is used to order logs by timestamp in ELK
# beacuse a lot of log messages have the same timestamp down to milliseconds
# so this tricky delay will split logs and order will restore in universe
# and there will be no more wars and children will play
class DelayLogger:
    def __init__(self, logger):
        self.l = logger
        self.prefix = ''

    def addPrefix(self, prefix):
        self.prefix = self.prefix + '@' + str(prefix)

    def debug(self, msg):
        sleep(0.05)
        self.l.debug(self.prefix + ' ' + str(msg))

    def info(self, msg):
        sleep(0.05)
        self.l.info(self.prefix + ' ' + str(msg))

    def warning(self, msg):
        sleep(0.05)
        self.l.warning(self.prefix + ' ' + str(msg))

    def error(self, msg):
        sleep(0.05)
        self.l.error(self.prefix + ' ' + str(msg))

    def critical(self, msg):
        sleep(0.05)
        self.l.critical(self.prefix + ' ' + str(msg))


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
