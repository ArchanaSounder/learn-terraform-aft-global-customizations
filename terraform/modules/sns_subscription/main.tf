# Creation for SNS Topic Subscription
resource "aws_sns_topic_subscription" "sns_subscription" {
  count     = var.sns_topic_enable == 1 ? 1 : 0
  topic_arn = var.topic_arn
  protocol  = var.protocol
  endpoint  = var.endpoint
}