module "sqs" {
  source      = "./modules/sqs"
  name        = "pii-test-ru"
  environment = "Test"

  #Enable Fifo
  #enable_fifo_queue           = true
  #content_based_deduplication = true

  #sqs_dead_letter_queue_arn   = "arn:aws:sqs:us-east-1:316963130188:my_sqs"
}

##############
#Policy attach#
###############
data "aws_iam_policy" "SQSAccess" {
  arn = "arn:aws:iam::860702706577:policy/PiiSQSAcessPolicyTestRu"
}

resource "aws_iam_role_policy_attachment" "SQS_attach" {
  role       = "role_name"
  policy_arn = data.aws_iam_policy.SQSAccess.arn
}
