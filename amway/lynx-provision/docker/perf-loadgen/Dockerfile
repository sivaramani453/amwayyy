# version: 1.0.0

FROM centos:7

# Set environment variables.
ENV JAVA_HOME /usr/java/latest

# Add build user
RUN adduser jmeter && \
    echo "jmeter ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Define working directory.
WORKDIR /home/jmeter
USER root

RUN yum update -y && yum clean all && \
    yum install -y sudo && yum clean all && \
    yum -y install openssh-server epel-release wget zip unzip && yum clean all && \
    wget -q http://10.130.115.53/static-dev/jdk-8u172-linux-x64.rpm && yum clean all && \
    yum localinstall -y jdk-8u172-linux-x64.rpm && yum clean all && \
    rm -f /etc/ssh/ssh_host_ecdsa_key /etc/ssh/ssh_host_rsa_key && \
    ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_ecdsa_key && \
    ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key && \
    sed -i "s/#PasswordAuthentication.*/PasswordAuthentication no/g" /etc/ssh/sshd_config && \
    sed -i "s/#PubkeyAuthentication.*/PubkeyAuthentication yes/g" /etc/ssh/sshd_config

USER jmeter
RUN mkdir -p /home/jmeter/.ssh
RUN echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDoHuvYVbIMfMr4ahvF+tiXf0/DMV1Dsjy1vABXuvdTFT0P+Ii+waQKm0f0xGyPfFAaL0tYwwzdJ6TGmwHIbfW4HP7KVa+BsGhR4kafZTvzrLJYizsJncXsTQ+1TO+dlYaSLWYFvIxY+VILckJBhwxT/0tbvnPrdnhHpXLE0QjpLVaD6BCqYEOzjnx4FahnDGEcBb7lgx6K4eJnJ2oz1+8cfJ4wKLBvg+EueKfGQqQcXMt9BSn4L6zHFLyONallAYRVV2dVGxhK0abX9kRlCzUXVHfwqJGfnsQWN+srazo1MBuBNH86sUcSJUz4KPyDNwPr9zIHLvgdRUfGfuD+WacbMqaF4ilBlEiZZZWtEkgnnYt9AaFxevB3pIYK2LnWHN8bynw0aa96DtTsIrl6IQnwGCdqRJx9Rbgwc2eRImnu+rsYnQi4nnwMujxps4RlCNZmyyVqI6hfNN/+S3FHA4TpV8nphaO2K5WlMxUCAlXzHnIhz3K3pZ6ri45s3wm4gWBlgRyJ+1Tb36lKurF1PiqeP6iOehqrxGXipztYscFL9yJ5Tke7yZaCk/CZjFLJ5LgoHWQaRPrOMiHzjf/ucy7uz1RM8ws2e1q8BZpG0BaK2sl+TtbmvQ86JfJt3rVyv7+SSGxepDbTrUdqUi/J3sN1frzkm6HJynXSwnT9aBQA3w==" > /home/jmeter/.ssh/authorized_keys

# Define default command.
USER root
CMD ["/usr/sbin/sshd", "-D"]