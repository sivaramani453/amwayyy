# DHCP
resource "aws_default_vpc_dhcp_options" "mumbai_default" {
  provider = "aws.mumbai"

  tags = {
    Name      = "default"
    Terraform = "true"
  }
}

resource "aws_vpc_dhcp_options" "amway_dns" {
  provider            = "aws.mumbai"
  domain_name_servers = ["172.30.54.10", "172.30.54.140"]

  tags = {
    Name      = "amway-dns"
    Terraform = "true"
  }
}

resource "aws_vpc_dhcp_options_association" "amway_dns_resolver" {
  provider        = "aws.mumbai"
  vpc_id          = "${aws_vpc.mumbai_dev.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.amway_dns.id}"
}

# Internet gateway
resource "aws_internet_gateway" "mumbai_default" {
  provider = "aws.mumbai"
  vpc_id   = "${aws_default_vpc.mumbai_default.id}"

  tags = {
    Name      = "default"
    Terraform = "true"
  }
}

resource "aws_internet_gateway" "mumbai_main" {
  provider = "aws.mumbai"
  vpc_id   = "${aws_vpc.mumbai_dev.id}"

  tags = {
    Name      = "epam-internet-gateway"
    Terraform = "true"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "mumbai_nat" {
  provider      = "aws.mumbai"
  allocation_id = "${aws_eip.mumbai_nat.id}"
  subnet_id     = "${aws_subnet.mumbai_nat.id}"

  tags = {
    Name      = "epam-nat-gateway"
    Terraform = "true"
  }
}

# Elastic IP
resource "aws_eip" "mumbai_nat" {
  provider = "aws.mumbai"
  vpc      = true

  tags = {
    Name      = "epam-nat-gateway"
    Terraform = "true"
  }
}

resource "aws_key_pair" "mumbai_main" {
  provider   = "aws.mumbai"
  key_name   = "ansible_rsa"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCzX3UBP+PcRwT+KtM3jxlAPrsihEaFaKN74SafmeL0WwCCIk0doHihXc4/bW3Np1VgV8b9Jlr63g7eIFlzdlG3KxqFXFbG+TF/oNjmdmConzQ0uj7l75+xBEBYfN//ZEx5H9V5Am1G/gd/dCGUVV7lyae2CqipNwHsPcfweQixg5huh1cn8511fpYDKSRdVI+qF3flBo6lwNALQI23+TJ8mGHW/Hj3iw1FWD3JqK/gKr1Wvrit1v7gCDQ8wNDVRp/3FElCrH+DQlXgs74x7z6NeZbGUvCfLwOuDFVWOFQr2mvBDpNuCVEB188bHWW2dj9dzv3YCFIGxoPP2dUUIFur root@ip-10-130-115-168.aweia.technicaldomain.ml"
}
