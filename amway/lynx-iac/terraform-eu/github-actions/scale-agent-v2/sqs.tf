resource "aws_sqs_queue" "webhook_queue" {
  name                      = "gh-scale-agent-v2-${terraform.workspace}-queue"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 86400
  receive_wait_time_seconds = 0
  visibility_timeout_seconds = 900

  tags = local.amway_common_tags
}