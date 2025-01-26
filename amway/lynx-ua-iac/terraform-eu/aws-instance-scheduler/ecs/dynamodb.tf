module "instance_scheduler_dynamodb_users_table" {
  source = "terraform-aws-modules/dynamodb-table/aws"

  name           = "${var.ecs_service_name}-users"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "username"

  attributes = [
    {
      name = "username"
      type = "S"
    }
  ]

  tags = merge(local.amway_common_tags, local.amway_data_tags)
}

module "instance_scheduler_dynamodb_groups_table" {
  source = "terraform-aws-modules/dynamodb-table/aws"

  name           = "${var.ecs_service_name}-groups"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "group_name"

  attributes = [
    {
      name = "group_name"
      type = "S"
    }
  ]

  tags = merge(local.amway_common_tags, local.amway_data_tags)
}

module "instance_scheduler_dynamodb_default_schedule_table" {
  source = "terraform-aws-modules/dynamodb-table/aws"

  name           = "${var.ecs_service_name}-default-schedule"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "instance_name"

  attributes = [
    {
      name = "instance_name"
      type = "S"
    }
  ]

  tags = merge(local.amway_common_tags, local.amway_data_tags)
}
