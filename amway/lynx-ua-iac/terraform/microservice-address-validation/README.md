
# AWEU Address Validation Setup

With this terraform you can pretty easily create Zookeer and Solr nodes and also PostgreSQL Database in AWS RDS.
Moreover, we have included an local-exec with ansible provisioning playbook, which will help you to gather all parts into the working cluster.

## Getting started
First what you need to do, is to clone several repositories, apart from **lynx-iac** and **lynx-provision** you also need **microservice-address-validation-adapter** and **microservice-address-validation**

- https://github.com/AmwayEIA/lynx-iac
- https://github.com/AmwayEIA/lynx-provision
- https://github.com/AmwayEIA/microservice-address-validation
- https://github.com/AmwayEIA/microservice-address-validation-adapter

## Rock and Roll
To get all parts together you need to perform several manual steps.
1. Copy ansible playbook files from `./lynx-provision/ansible/microservices-address-validation` to `./lynx-iac/terraform/microservices-address-validation/ansible`.
2. In address validation we are using additional plugin for Solr. This plugin needed for python adapter and is used to notify about the completion of the upload. Moreover, we have uploaded it into the nexus, but you could also find it in `microservice-address-validation-adapter` repository under path `./microservice-address-validation-adapter/solr_plugin/bin/`.

   **IMPORTANT:** In terraform you could find several options related  for this plugin, they are
   ```java
   -Dadapter_auth_credentials=${var.adapter_auth_user}:${var.adapter_auth_pass} 
   -Devent_sender_1_data=https://${var.address_validation_url}/api/v1/adapter/kz/solr_job_done
   -Devent_sender_2_data=https://${var.address_validation_url}/api/v1/adapter/ru/solr_job_done
   ```

   The very crucial moment about those options is the country and sender number correlation. It must be **SENDER_1 = KZ** and **SENDER_2 = RU** and not the other way. **Moreover, you must always set both parameters**, even if you create address validation for only one country e.g RU. Also I would like to draw your attention to additional parameter **-Dadapter_auth_credentials** in which you should pass authentication credentials for API calls made to python adapter . 
   
3. Change directory to `./lynx-iac/terraform/microservice-address-validation/` and run `terraform init`, please, keep in mind in this installation we are using the concept of `terrform workspaces`. After you intialize terraform, execute `terraform workspace new address-validation-eks-dev`. Terraform will create a new workspace called `address-validation-eks-dev` moreover, in s3 bucket you should see the following underlying structure where terraform stores it state.
   ```
   env:
      address-validation-eks-dev
          address-validation.tfstate
      address-validation-perf-ru
          address-validation.tfstate
      address-validation-qa-ru
          address-validation.tfstate
      address-validation-qa-kz
          address-validation.tfstate
      address-validation-test
          address-validation.tfstate
   ```

   **IMPORTANT:** **We use the name of a workspace as variable** to distinguish between installations. For details, please see the source code.
   
4. Next step after initialization, change directory to `./lynx-iac/terraform/microservices-address-validation/` is to run `terraform apply` and it will ask for:
   - A root user password for PostgreSQL. 
   - A microservice user for PostgreSQL.
   - A microservice user password for PostgreSQL.
   - A python adapter user for API Calls.
   - A python adapter password for API Calls.
   - A path to **EPAM-SE.pem** on your local file system, which is needed for ansible.
   - The address validation url (e.g: **address-validation-ru-qa.hybris.eia.amway.ne**)

   Alternatively you could use `terraform.tfvars` file with answers from vault, which was originally used for cluster creation. e.g: `vault kv get -field=terraform.tfvars /microservices/address-validation/qa-ru-tfvars > ./terraform.tfvars`.

**IMPORTANT:** By default terraform will create three nodes for Zookeeper and two nodes for Solr, you can adjust those parameters in variables.tf however, bear in mind that you can't create less then three nodes for Zookeeper.

5. After terraform finishes, go to https://console.aws.amazon.com/rds/home and temporarly adjust security group rule for RDS.

   Change ingress settings to allow connection form **VPN range subnets** ("10.0.0.0/8", "172.16.0.0/12"). 
After you've done this, got to `./microservice-address-validation/pg_sql_init` and execute `./init.sql` via `psql`.
e.g: `psql -U root -h rds_url_from_terraform_output -W postgres < ./init.sql` 
This script will create **user,database,schema and grant all necessary permissions**.
Don't forget to change back the ingress rule to it original state, it should be bound only to VPC subnets. If in doubt please see the source code of terraform. Or just run `terraform apply` once again :)

**IMPORTANT:** Next steps you need to execute only if you are planning to use both countries for the particular 'line' of the address-validation microservice. As by default in the deployment of the address-validation we use init container for python adapter, which uploads solr config set based on the country. e.g: for qa-ru it will upload conf_ru. 

6. We are almost done, copy config sets: **conf_kz** and **conf_ru** from `./microservice-address-validation-adapter/solr_configs` to any Solr node.

   Execute following command to upload them to Zookeeper: `/opt/solr/bin/solr zk -upconfig -n conf_ru -d conf_ru -z zookeeper_url_from_terraform_output:2181` You must execute this command for both **conf_ru** and **conf_kz**.
7. Last step, copy **RDS DNS** name and **DNS** names for **Zookeeper** and **Solr** nodes, you need them for **Helm Chart**.

That is all folks, if you have any question, feel free to ask Vladimir Antropov.
