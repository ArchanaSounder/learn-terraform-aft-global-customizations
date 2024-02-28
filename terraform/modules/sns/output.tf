# Output declaration for sns topic id
output "sns_topic_id" {
  value = aws_sns_topic.sns_topic.id
}