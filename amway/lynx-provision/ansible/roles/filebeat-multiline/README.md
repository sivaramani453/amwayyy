Filebeat multiline
=========
[![build status](https://git.epam.com/dip-roles/filebeat-multiline/badges/master/build.svg)](https://git.epam.com/dip-roles/filebeat-multiline/pipelines)

This role can be used to install Filebeat pipeline (filebeat-awk-filebeat) on Centos 6,7 or Windows host. 

Filebeat versions supported: all stable versions from 5 and 6 branches. Filebeat can have versions 5.x.x or 6.x.x so far.

For log processing we use following mechanism:

1) Log files scanned by first ( 1 ) instance of filebeat;

2) Scanned data processed by linux pipe to awk (which is configured with special awk config file);

3) Well-formed JSONs from awk stdout processed by linux pipe to the second ( 2 ) instance of filebeat;

4) Second instance of filebeat sends this data to specified output (Logstash or Elasticsearch);

After successful install running service looks like below:

```
CGroup: /system.slice/filebeat-pipeline.service
           ├─12943 /bin/bash -c set -o pipefail; set -e; /usr/share/filebeat/bin/filebeat -c /etc/filebeat/filebeat-in.yml | /bin/awk -f /etc/filebeat/parsing-pipeline.awk | /usr/shar...
           ├─12944 /usr/share/filebeat/bin/filebeat -c /etc/filebeat/filebeat-in.yml
           ├─12945 /bin/awk -f /etc/filebeat/parsing-pipeline.awk
           └─12946 /usr/share/filebeat/bin/filebeat -c /etc/filebeat/filebeat-out.yml
```


## Known issues

Idempotence test fails on "Create service via nssm" task due [official ansible open issue](https://github.com/ansible/ansible/issues/20625).
Temporary added change_when: False option as a workaround.

## Requirements
Properly written inventory file. 

[ca-cert role](https://git.epam.com/dip-roles/ca-cert)[![build status](https://git.epam.com/dip-roles/ca-cert/badges/master/build.svg)](https://git.epam.com/dip-roles/ca-cert/pipelines) required in case of SSL transfer is supposed to be used for log shipping.

[Prepared Windows System](http://docs.ansible.com/ansible/latest/intro_windows.html#windows-system-prep)

Properly working [awk](https://www.gnu.org/software/gawk/) is supposed to be present on target system. It's included in any modern Linux distribution by default. 

For Windows case this role installs Windows version of awk automatically. 

For Linux awk is updated to 4.2.1 if installed version is lower.

## Role Variables
Variable `filebeat_version` specifies version of filebeat to be installed. It can be set as strict version value like '5.6.5' or branch version like '5.x' or '6.x'. 
Default value is '6.x'. It means that last available version of 6.x branch will be installed.

Operate variable `filebeat_output` to set where data will be transferred.
Available values: `elasticsearch`, `logstash`. Default value is `elasticsearch`.
```
filebeat_output: elasticsearch
```

For each type of output connection details (`host` and `port` subelements) have to be specified with optional values `es` or `ls` for elasticsearch and logstash respectively:
```
    es:
      host: elastichost.example.com
      port: 9200
```

Variable `filebeat_inputs` defines type of logs that will be processed by pipeline, their log paths and Elasticsearch index that should store this type of logs. 
You can specify several inputs with various paths, logtypes and index names using yaml format like in example below:
```
    filebeat_inputs:
      - name: hybris
        paths: 
          - '/var/log/console*.log'
        fields:
          logtype: hybris
          index_name: hybris-console
      - name: access
        paths: 
          - '/var/log/access*.log'
          - '/var/log/nginx_access*.log'
        fields:
          logtype: access
          index_name: nginx-access
```

The most important variable of inputs is `logtype` which specifies type of log to be parsed by corresponding AWK parser.
Available values: `hybris`, `access`, `weblogic`, `solr`, `java`. More types can be added according to requirements in the future.

Operate variable `filebeat_ssl_enabled` to turn on/off SSL connection between filebeat and logstash/elasticsearch.
SSL options should be set by corresponding dict fields like shown below:
```
  ssl:
    key: 'c:\tls\private\server.key'
    certificate: 'c:\tls\certs\server.pem'
    certificate_authorities: 'c:\CA\ca-root.pem'
```

The `path` section of the configuration options defines where Filebeat looks for its files. 
For example, Filebeat looks for the Elasticsearch template file in the configuration path and writes log files in the logs path. 
Filebeat looks for its registry files in the data path. Default values for Linux host are set up this way:
```
path:
  home: /usr/share/filebeat
  config: /etc/filebeat
  data: /var/lib/filebeat
  logs: /var/log/filebeat
```
in case of Windows setup default paths look like:
```
path:
  home: 'c:\program files\filebeat'
  config: 'c:\program files\filebeat'
  data: 'c:\programdata\filebeat'
  logs: 'c:\programdata\filebeat\logs'
```

Custom user-specified fields can also be added to Elasticsearch fields for each client. 
The following options are available for custom details:
- `filebeat_node_name`: name setting value for `beat.name` field. Default value is `filebeat`
- `tags`: custom list of user-specified data added to each message with the same `tags` name
- `filebeat_custom_fields`: optional variable containing dictionary with custom details to be added like separate additional fields for each Elasticsearch message

Example usage of `filebeat_custom_fields`:
```
filebeat_custom_fields:
  env: prod
  subnet: production-customer
  subtype: front-end
```

## Dependencies
- ca-cert (only for installation with SSL)

## SELinux
No problems with SELinux were found. In a case of any additional issues you should [disable SELinux Temporarily or Permanently](https://www.tecmint.com/disable-selinux-temporarily-permanently-in-centos-rhel-fedora/).
You can use some steps as example based on [elk5-nginx](https://git.epam.com/epm-ldi/elk5-nginx/blob/master/tasks/selinux-elk5-nginx.yml) or [zabbix-server](https://git.epam.com/epm-ldi/zabbix-server/blob/master/tasks/selinux-zabbix-server.yaml) implementations.

## Examples
Inventory
```
[ca-root]
ca-root.example.com
[logstash]
logstash.example.com
[filebeat]
filebeat.example.com
```
Playbook for installing on Linux client (use it as an example only!):
```
- name: Install filebeat multiline
  hosts: filebeat
  vars:
    filebeat_version: 6.x
    filebeat_output: elasticsearch
    es:
      host: client.example.com
      port: 9200
    filebeat_inputs:
      - name: hybris
        paths: 
          - '/var/log/console*.log'
        fields:
          logtype: hybris
          index_name: hybris-console
  roles:
     - role: ca-cert
     - role: filebeat-multiline
```

Playbook for installing filebeat-multiline flow on Windows client (use it as an example only!):
```
- name: install filebeat-multiline hybris flow
  hosts: filebeat
  vars:
    filebeat_version: 6.x
    filebeat_output: elasticsearch
    es:
      host: client.example.com
      port: 9200
    filebeat_inputs:
      - name: hybris
        paths: 
          - 'C:\\logs\\console*'
        fields:
          logtype: hybris
          index_name: hybris-console
  roles:
     - role: filebeat-multiline
```

For example, such logs as general java application logs with multiline and stacktraces can be processed by `java` type of current service. 
Source log can look like this:
```
2018-05-17 11:02:38,352 [qtp1790421142-26              ] ERROR NodePoolServlet                - Validation error. WF host parameter is required
java.lang.NullPointerException: Validation error. WF host parameter is required
        at java.util.Objects.requireNonNull(Objects.java:228)[:1.8.0_144]
        at ru.qatools.gridrouter.node.model.NodeRequest.<init>(NodeRequest.java:32)[rpa-gridrouter-proxy-9.1.0-REDESIGN-SNAPSHOT-classes.jar:]
        at ru.qatools.gridrouter.node.NodePoolServlet.processAction(NodePoolServlet.java:60)[rpa-gridrouter-proxy-9.1.0-REDESIGN-SNAPSHOT-classes.jar:]
        at ru.qatools.gridrouter.node.NodePoolServlet.process(NodePoolServlet.java:51)[rpa-gridrouter-proxy-9.1.0-REDESIGN-SNAPSHOT-classes.jar:]
        at ru.qatools.gridrouter.node.NodePoolServlet.doGet(NodePoolServlet.java:41)[rpa-gridrouter-proxy-9.1.0-REDESIGN-SNAPSHOT-classes.jar:]
        at javax.servlet.http.HttpServlet.service(HttpServlet.java:687)[jetty-runner.jar:9.3.3.v20150827]
        at javax.servlet.http.HttpServlet.service(HttpServlet.java:790)[jetty-runner.jar:9.3.3.v20150827]
        at org.eclipse.jetty.servlet.ServletHolder.handle(ServletHolder.java:816)[jetty-servlet-9.3.6.v20151106.jar:9.3.3.v20150827]
        at org.eclipse.jetty.servlet.ServletHandler.doHandle(ServletHandler.java:583)[jetty-servlet-9.3.6.v20151106.jar:9.3.3.v20150827]
        at org.eclipse.jetty.server.handler.ScopedHandler.handle(ScopedHandler.java:143)[jetty-server-9.3.6.v20151106.jar:9.3.3.v20150827]
        at org.eclipse.jetty.security.SecurityHandler.handle(SecurityHandler.java:513)[jetty-security-9.3.6.v20151106.jar:9.3.3.v20150827]
        at org.eclipse.jetty.server.session.SessionHandler.doHandle(SessionHandler.java:226)[jetty-server-9.3.6.v20151106.jar:9.3.3.v20150827]
        at org.eclipse.jetty.server.handler.ContextHandler.doHandle(ContextHandler.java:1156)[jetty-server-9.3.6.v20151106.jar:9.3.3.v20150827]
        at org.eclipse.jetty.servlet.ServletHandler.doScope(ServletHandler.java:511)[jetty-servlet-9.3.6.v20151106.jar:9.3.3.v20150827]
        at org.eclipse.jetty.server.session.SessionHandler.doScope(SessionHandler.java:185)[jetty-server-9.3.6.v20151106.jar:9.3.3.v20150827]
        at org.eclipse.jetty.server.handler.ContextHandler.doScope(ContextHandler.java:1088)[jetty-server-9.3.6.v20151106.jar:9.3.3.v20150827]
        at org.eclipse.jetty.server.handler.ScopedHandler.handle(ScopedHandler.java:141)[jetty-server-9.3.6.v20151106.jar:9.3.3.v20150827]
        at org.eclipse.jetty.server.handler.ContextHandlerCollection.handle(ContextHandlerCollection.java:213)[jetty-server-9.3.6.v20151106.jar:9.3.3.v20150827]
        at org.eclipse.jetty.server.handler.HandlerCollection.handle(HandlerCollection.java:109)[jetty-server-9.3.6.v20151106.jar:9.3.3.v20150827]
        at org.eclipse.jetty.server.handler.HandlerWrapper.handle(HandlerWrapper.java:119)[jetty-server-9.3.6.v20151106.jar:9.3.3.v20150827]
        at org.eclipse.jetty.server.Server.handle(Server.java:517)[jetty-server-9.3.6.v20151106.jar:9.3.3.v20150827]
        at org.eclipse.jetty.server.HttpChannel.handle(HttpChannel.java:306)[jetty-server-9.3.6.v20151106.jar:9.3.3.v20150827]
        at org.eclipse.jetty.server.HttpConnection.onFillable(HttpConnection.java:242)[jetty-server-9.3.6.v20151106.jar:9.3.3.v20150827]
        at org.eclipse.jetty.io.AbstractConnection$ReadCallback.succeeded(AbstractConnection.java:245)[jetty-io-9.3.6.v20151106.jar:9.3.3.v20150827]
        at org.eclipse.jetty.io.FillInterest.fillable(FillInterest.java:95)[jetty-io-9.3.6.v20151106.jar:9.3.3.v20150827]
        at org.eclipse.jetty.io.SelectChannelEndPoint$2.run(SelectChannelEndPoint.java:75)[jetty-io-9.3.6.v20151106.jar:9.3.3.v20150827]
        at org.eclipse.jetty.util.thread.strategy.ExecuteProduceConsume.produceAndRun(ExecuteProduceConsume.java:213)[jetty-util-9.3.6.v20151106.jar:9.3.3.v20150827]
        at org.eclipse.jetty.util.thread.strategy.ExecuteProduceConsume.run(ExecuteProduceConsume.java:147)[jetty-util-9.3.6.v20151106.jar:9.3.3.v20150827]
        at org.eclipse.jetty.util.thread.QueuedThreadPool.runJob(QueuedThreadPool.java:654)[jetty-util-9.3.6.v20151106.jar:9.3.3.v20150827]
        at org.eclipse.jetty.util.thread.QueuedThreadPool$3.run(QueuedThreadPool.java:572)[jetty-util-9.3.6.v20151106.jar:9.3.3.v20150827]
        at java.lang.Thread.run(Thread.java:748)[:1.8.0_144]
```
For this case you should set `logtype` to `java`. 

## License
Proprietary, property of EPAM Systems

## Author Information

DEP Infrastructure Framework Project Team <specialepm-ldidevops@epam.com>