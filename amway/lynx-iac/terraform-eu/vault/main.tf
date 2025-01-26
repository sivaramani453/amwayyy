data "template_file" "vault_user_data" {
  template = "${file("${path.module}/files/userdata.sh")}"

  vars = {
    cluster_name              = "${terraform.workspace}"
    region                    = data.aws_region.current.name
    vault_lb_dns_name         = "${terraform.workspace}.${local.route53_zone_name}"
    vault_data_bucket_name    = module.vault_data.s3_bucket_id
    vault_dynamodb_table_name = module.vault_dynamodb_table.dynamodb_table_id
    vault_kms_seal_key_id     = aws_kms_key.vault_seal.key_id
  }
}

module "vault_cluster" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 5.6.1"

  for_each       = local.core_subnet_ids
  name           = "${terraform.workspace}-node"
  # instance_count          = length(local.core_subnet_ids)

  ami                         = data.aws_ami.vault_node_ami.id
  instance_type               = "t3.micro"
  key_name                    = "test_pem"
  user_data                   = data.template_file.vault_user_data.rendered
  vpc_security_group_ids      = [module.vault_cluster_sg_ec2.security_group_id]
  subnet_id                   = each.key
  iam_instance_profile        = aws_iam_instance_profile.vault_iam_profile.name
  associate_public_ip_address = true
  source_dest_check           = true
  ebs_optimized               = true
  monitoring                  = false

  root_block_device = [
    {
      volume_type           = "gp2"
      volume_size           = "10"
      delete_on_termination = true
    },
  ]

  tags        = merge(local.amway_common_tags, local.amway_ec2_tags)
  volume_tags = merge(local.amway_common_tags, local.amway_data_tags)
}

module "vault_resources" {
  source = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 4.1.2"
  bucket = "${terraform.workspace}-s3-resources"
  # acl    = "private"

  versioning = {
    enabled = true
  }

  lifecycle_rule = [
    {
      id      = "vault-resources-s3-lifecycle-rule"
      enabled = true
      prefix  = "resources/"

      abort_incomplete_multipart_upload_days = 7

      noncurrent_version_expiration = {
        days = "7"
      }
    },
  ]

  tags = merge(local.amway_common_tags, local.amway_data_tags)

}

module "vault_data" {
  source = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 4.1.2"
  bucket = "${terraform.workspace}-s3-data"
  # acl    = "private"

  versioning = {
    enabled = true
  }

  lifecycle_rule = [
    {
      id      = "vault-data-s3-lifecycle-rule"
      enabled = true

      abort_incomplete_multipart_upload_days = 7

      noncurrent_version_expiration = {
        days = "7"
      },
    }
  ]

  tags = merge(local.amway_common_tags, local.amway_data_tags)

}

module "vault_dynamodb_table" {
  source = "terraform-aws-modules/dynamodb-table/aws"
  version = "~> 4.0.1"
  name           = "${terraform.workspace}-ha-coordination"
  # read_capacity  = 5
  # write_capacity = 5
  hash_key       = "Path"
  range_key      = "Key"

  attributes = [
    {
      name = "Path"
      type = "S"
    },
    {
      name = "Key"
      type = "S"
    },
  ]

  tags = merge(local.amway_common_tags, local.amway_data_tags)
}


resource "aws_kms_alias" "vault_seal" {
  name          = "alias/${terraform.workspace}/seal"
  target_key_id = aws_kms_key.vault_seal.key_id
}

resource "aws_kms_key" "vault_seal" {
  description         = "KMS key used for ${terraform.workspace} seal"
  enable_key_rotation = true

  tags = local.amway_common_tags
}
