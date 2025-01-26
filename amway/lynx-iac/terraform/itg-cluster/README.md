# IT-GRAD K8S cluster

Terraform part creates S3 bucket with IAM user for etcd backups; Route53 records for monitoring and API endpoint. vApp templates (e.g AMIs) for centos-golden and rke-node were already created. New nodes can be spawmned using rke-node template.

## Centos golden template is created with steps below:

*1 vApp = 1 VM*
- Create vApp
- Add network to vApp. IP Assignment: IP - Pool
- Create VM inside this vApp without template, powered off. _Computer name_ = hostname that will be visible in kubernetes.
- Increase disk size in VM options. 
- Insert CD/DVD with uploaded CentOS image.
- Start VM and install centos via Web Console. 
Adjust partition manually: No swap, 1GB for boot volume, rest for /.
Provide default root password (keep it simple, it will be changed later in installation). Connect it to network, assign IP manually, DHCP is not working here.
- Connect to VM.
- Install VMWare tools via WebConsole.
- Basic provision:
```
yum -y update && yum -y install perl cloud-utils-growpart
# Disable Selinux

# In case you increased disk size after installation
growpart /dev/sda 2
pvresize /dev/sda2
lvextend -l +100%FREE /dev/mapper/centos-root
xfs_growfs /dev/mapper/centos-root

# VMWare tools insallation. (during vmware-install.pl run first answer is yes)
mkdir /mnt/cdrom
mount /dev/cdrom /mnt/cdrom
cp /mnt/cdrom/VMwareTools-*.tar.gz /tmp
umount /mnt/cdrom
tar -zxf /tmp/VMwareTools-*.tar.gz -C /tmp
cd /
./tmp/vmware-tools-distrib/vmware-install.pl
rm -f /tmp/VMwareTools-*.tar.gz
rm -rf /tmp/vmware-tools-distrib

# SSH key
mkdir ~/.ssh
touch ~/.ssh/authorized_keys
# copy ansible_rsa key
```
- Power Off the VM
- Eject Media
- Enable Guest customizations
- Power On and Force Custiomization. Now VM should be reacheable via IP that you see in Web Console.

## RKE node template is created with steps below:
- Provision nodes with docker: https://github.com/AmwayEIA/lynx-provision/tree/master/ansible/rke-host
- Add ansible_rsa key to /home/centos/.ssh/authorized_keys. 
(chmod -R 700 /home/centos/.ssh)


## Provision kubernetes cluster with RKE
Populate `provision/cluster.yaml` with:
* IP adresses
* SANs (fqdn can be obtainet from terraform)
* SSH key path
* Bucket name (from terraform output)
* Bucket credentials (from tfstate file on S3 backend bucket)
```
rke up --config provision/cluster.yaml
```

## Upload latest cluster state, config and import file from rancher to S3 backup bucket

```
aws s3 cp cluster.rkestate s3://amway-test-itg-cluster-etcd-backup/

aws s3 cp kube_config_cluster.yaml s3://amway-test-itg-cluster-etcd-backup/

aws s3 cp import.yaml s3://amway-test-itg-cluster-etcd-backup/
```

## Install K8S components
* Install monitoring: https://github.com/AmwayEIA/microservice-helm-charts/tree/master/prometheus-stack

Create Read Only user U: read P: only Email: readonly@localhost
* Install logging: https://github.com/AmwayEIA/microservice-helm-charts/tree/master/microservice-filebeat

Index: kubernetes-itg-dev



# Networking

## IT-GRAD Loadbalancer consists of:
- `Application Profile` (AWS ELB Listener type?) - TCP, HTTP or HTTPS
- `Service monitoring` (AWS ELB health check) - Protocol type, intervals, URL for hc, etc.
- `Pool` (AWS ELB Target group) - List of IPs to route traffic to; Service monitoring assignment for hc; Monitor port = HC port. Port = port to route traffic to.
- `Virtual Server` (AWS ALB\NLB) - LoadBalancer itself. Application profile assignment, Pool assignment. IP Address - IP of loadbalancer (can be internal or external), Protocol - Listener protocol, Port - Listener port

### _API_
Route53 - IT-GRAD internal Network LoadBalancer (Listener: TCP 6443, HC: TCP 6443) - Pool of K8S master nodes (Targets: TCP 6443)

### _Monitoring_
Route53 - IT-GRAD internal Network LoadBalancer (Listener: TCP 80, HC: HTTP 80 /healthz) - Pool of K8S worker nodes (Targets: TCP 80)

### _Ingress external_
Amway DNS - IT-GRAD external Network LoadBalancer (Listener: TCP 443, HC: HTTP 80 /healthz) - Pool of K8S worker nodes (Targets: TCP 443)

### _Ingress internal_
Amway DNS/Route 53 - IT-GRAD internal Network LoadBalancer (Listener: TCP 443, HC: HTTP 80 /healthz) - Pool of K8S worker nodes (Targets: TCP 443)
