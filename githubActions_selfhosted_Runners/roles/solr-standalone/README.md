Solr Standalone
=========

This role can be used to install solr standalone on Centos 7 or Windows host. 

For additional configuration, such as master or slave mode use roles solr-master, solr-slave, solr-change.

## Requirements
Properly written inventory file.

[Prepared Windows System](http://docs.ansible.com/ansible/latest/intro_windows.html#windows-system-prep)

## Role Variables
Variable `SOLR_VERSION` matches available version on https://archive.apache.org/dist/lucene/solr/

Tested versions 5.3-7.1.x
```
SOLR_VERSION: 7.1.0
```
Operate variable `SOLR_MASTER_HEAP` to configure Java Heap on Linux target as needed to support your indexing / query needs
```
SOLR_MASTER_HEAP: "512m"
```
Operate variable `WIN_SOLR_MASTER_HEAP` to configure Java Heap on Windows target as needed to support your indexing / query needs
```
WIN_SOLR_MASTER_HEAP: -Xms512m -Xmx512m
```

Variable `SOLR_MASTER_ENABLE_JMX` can be used to turn on/off solr JMX listener.
```
SOLR_MASTER_ENABLE_JMX: false
```
Solr standalone can be installed with SSL support, which can be configured by variables below or turned off by commenting variable `SOLR_SSL_KEY_STORE`
```
SOLR_SSL_KEY_STORE_PATH: "/opt/solr/server/etc"
SOLR_SSL_KEY_STORE_NAME: "solr-ssl.keystore.jks"
SOLR_SSL_KEY_STORE: "{{ SOLR_SSL_KEY_STORE_PATH }}/{{ SOLR_SSL_KEY_STORE_NAME }}"
SOLR_SSL_KEY_STORE_PASSWORD: secret
SOLR_SSL_TRUST_STORE: "{{ SOLR_SSL_KEY_STORE_PATH }}/{{ SOLR_SSL_KEY_STORE_NAME }}"
SOLR_SSL_TRUST_STORE_PASSWORD: secret
SOLR_SSL_NEED_CLIENT_AUTH: false
SOLR_SSL_WANT_CLIENT_AUTH: false
SOLR_SSL_KEY_STORE_TYPE: JKS
SOLR_SSL_TRUST_STORE_TYPE: JKS
```
Certificate related parameters from [dependent role](https://git.epam.com/dip-roles/ca-cert) should be provided to enable SSL
```
CA_DOMAIN: "example.com"
CA_CERT_FILE_PATH: "/etc/pki/CA/certs"
CA_CERT_FILE_NAME: "{{ CA_DOMAIN }}.ca-cert.pem"
LOCAL_PKEY_FILE_PATH: "/etc/pki/tls/private"
LOCAL_PKEY_FILE_NAME: "{{ ansible_hostname }}.ca-pkey.pem"
LOCAL_CERT_FILE_PATH: "/etc/pki/tls/certs"
LOCAL_CERT_FILE_NAME: "{{ ansible_hostname }}.ca-cert.pem"
```
In addition to SSL, basic authentication is configured for versions 7.x.x

Comment variable `SOLR_AUTH_TYPE` to disable this option. 
```
CHANGE_DEFAULT_PASSWORD: true
SOLR_AUTH_TYPE: "basic"
SOLR_AUTH_USER: "solrserver"
SOLR_AUTH_PASS: "server123"
```
Password for default solr user can be changed by setting up `CHANGE_DEFAULT_PASSWORD` to `true`. (Will be changed to `SOLR_AUTH_PASS` value)

Variables `SOLR_AUTH_USER` and `SOLR_AUTH_PASS` are used for creating new user.

Integration with hybris can be enabled by defining variables:
```
SOLR_INTERGRATIONS: "hybris"
HYBRIS_PACKAGE_NAME: HYBRISCOMM6600P_0-70003031 (example)
```
Switch variable `SOLR_WITH_SYSTEMD` to change type of solr installation (systemd or init.d)
```
SOLR_WITH_SYSTEMD: true
```

## Dependencies
- ca-cert (only for installation with SSL)
- oracle-java 

## SELinux
Problems in role with active SELinux were solved. In a case of any additional issues you should [disable SELinux Temporarily or Permanently](https://www.tecmint.com/disable-selinux-temporarily-permanently-in-centos-rhel-fedora/).
You can use some steps as example based on [elk5-nginx](https://git.epam.com/epm-ldi/elk5-nginx/blob/master/tasks/selinux-elk5-nginx.yml) or [zabbix-server](https://git.epam.com/epm-ldi/zabbix-server/blob/master/tasks/selinux-zabbix-server.yaml) implementations.

## Example Playbook
```
- name: standalone solr installation
  hosts: solr-standalone 
  roles:
     - role: oracle-java
     - role: ca-cert
     - role: solr-standalone
```
## License
Proprietary, EPAM

## Author Information
DEP Infrastructure Framework Project Team
