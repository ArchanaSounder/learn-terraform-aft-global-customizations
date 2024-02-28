# Resource creation for sns topic
resource "aws_sns_topic" "sns_topic" {
  count = var.sns_topic_enable == 1 ? 1 : 0
  name  = var.sns_topic_name
}

