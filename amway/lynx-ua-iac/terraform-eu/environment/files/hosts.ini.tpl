[fe1]
${fe1_instance_fqdn} instance_id="${fe1_instance_id}"

[fe2]
${fe2_instance_fqdn} instance_id="${fe2_instance_id}"

[be1]
${be1_instance_fqdn} instance_id="${be1_instance_id}"

[be2]
${be2_instance_fqdn} instance_id="${be2_instance_id}"


[solr_nodes:children]
fe1
fe2
be1

[solr_slaves:children]
fe2
be1

[all:vars]
solr_master_ip_address = "${fe1_instance_fqdn}"
