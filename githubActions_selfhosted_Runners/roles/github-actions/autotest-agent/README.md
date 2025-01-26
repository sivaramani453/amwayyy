# AmwayAutoQA Autotest runner

## Providing headless tests

You may still find some leftovers from previous approach, which was to provide headless X by TigerVNC. After switching distro from CentOS to Amazon Linux TigerVNC stopped working, and instead of debugging it I (Jan Machalica) decided to convert X to xvfb.

* It has to be run as a service, autostarted, at screen :1
* It has to use some kind of window manaer - otherwise chrome will not be able to maximize itself
* It has to run in HD 16 bits per pixel (1920x1080x16)
* Both xvfb and openbox needs to run as the same user who executes the tests

### Access X via VNC

I don't use TigerVNC, however it's still possible to access screen via VNC - by using x11vnc package. The command is:

<pre>
x11vnc -display :1 -bg -forever -nopw -quiet -xkb
</pre>

Obviously we need to install x11vnc with yum first.

### Capture Chrome network traffic

It does capture only headers, wihout request/response body.

When launching Chrome from CLI, we may pass some additional arguments that changes way Chrome works. One of those arguments are those related with network traffic capturing:
* '''--log-net-log=/path/to/log/file.json''' enables traffic capturing
* '''--net-log-capture-mode=IncludeSensitive'''
* '''--net-log-capture-mode=Everything'''

To display logs in a readable way, an online tool [https://netlog-viewer.appspot.com/] can be used.

We must remember that after every restart of Chrome, which may happen multiple times during test suite, logfile may be truncated. To avoid this situation, a tiny patch needs to be implemented. Filename should contain a random string, which is being changed everytime a ChromeOptions are being fetched. To implement those changes in test, you can put them in setChromeStartArguments method located in [https://github.com/AmwayACS/AmwayAutoQA/blob/master/amway-test-system-core/src/main/java/com/amway/core/utils/webdriver/DriverOptionsHelper.java] class.



