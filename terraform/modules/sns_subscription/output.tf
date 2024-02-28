# Output declaration for sns topic subscription
output "sns_subscription_id" {
  value = aws_sns_topic_subscription.sns_subscription.id
}