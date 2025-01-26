# GiHub Actions devdebug runner

## Timeout

We have a timeout being hardcoded for 4h, which is being set in install.sh script. Investigate line that executes runsvc.sh - it does it wrapped in timeout command, and by now the timeout is hardcoded. It can be parametrized at later time, if needed.

## Debugging

It would be great if we could detect if the runner is spawned by GitHub Actions webhook or rather manually. If manually, it would be nice to disable timeout and leave runner working, so some debugging can be taken.