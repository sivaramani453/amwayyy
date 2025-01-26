# DHCP
resource "aws_default_vpc_dhcp_options" "virginia_default" {
  provider = "aws.virginia"

  tags = {
    Name      = "default"
    Terraform = "true"
  }
}

resource "aws_vpc_dhcp_options" "amway_virginia_dns" {
  provider            = "aws.virginia"
  domain_name_servers = ["172.30.54.10", "172.30.54.140", "AmazonProvidedDNS"]

  tags = {
    Name      = "EPAM-VIRGINIA"
    Terraform = "true"
  }
}

resource "aws_vpc_dhcp_options_association" "amway_virginia_dns_resolver" {
  provider        = "aws.virginia"
  vpc_id          = "${aws_vpc.virginia_dev.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.amway_virginia_dns.id}"
}

# Internet gateway
resource "aws_internet_gateway" "virginia_default" {
  provider = "aws.virginia"
  vpc_id   = "${aws_default_vpc.virginia_default.id}"

  tags = {
    Name      = "default"
    Terraform = "true"
  }
}

resource "aws_internet_gateway" "virginia_main" {
  provider = "aws.virginia"
  vpc_id   = "${aws_vpc.virginia_dev.id}"

  tags = {
    Name      = "IGW-EPAM-VIRGINIA"
    Terraform = "true"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "virginia_nat" {
  provider      = "aws.virginia"
  allocation_id = "${aws_eip.virginia_nat.id}"
  subnet_id     = "${aws_subnet.virginia_nat.id}"

  tags = {
    Name      = "NAT-EPAM-VIRGINIA"
    Terraform = "true"
  }
}

# Elastic IP
resource "aws_eip" "virginia_nat" {
  provider = "aws.virginia"
  vpc      = true

  tags = {
    Name      = "EPAM-NAT-GATEWAY"
    Terraform = "true"
  }
}

resource "aws_key_pair" "virginia_main" {
  provider   = "aws.virginia"
  key_name   = "ansible_rsa.pem"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCzX3UBP+PcRwT+KtM3jxlAPrsihEaFaKN74SafmeL0WwCCIk0doHihXc4/bW3Np1VgV8b9Jlr63g7eIFlzdlG3KxqFXFbG+TF/oNjmdmConzQ0uj7l75+xBEBYfN//ZEx5H9V5Am1G/gd/dCGUVV7lyae2CqipNwHsPcfweQixg5huh1cn8511fpYDKSRdVI+qF3flBo6lwNALQI23+TJ8mGHW/Hj3iw1FWD3JqK/gKr1Wvrit1v7gCDQ8wNDVRp/3FElCrH+DQlXgs74x7z6NeZbGUvCfLwOuDFVWOFQr2mvBDpNuCVEB188bHWW2dj9dzv3YCFIGxoPP2dUUIFur root@ip-10-130-115-168.aweia.technicaldomain.ml"
}
