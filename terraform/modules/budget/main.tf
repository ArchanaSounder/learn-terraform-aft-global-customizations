# Create budget in master account

resource "aws_budgets_budget" "ec2" {
  name         = var.budget_name
  budget_type  = var.budget_type
  limit_amount = var.limit_amount
  limit_unit   = var.limit_unit
  time_unit    = var.time_unit
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_sns_topic_arns  = [aws_sns_topic.user_updates.arn]
    subscriber_email_addresses = var.subscriber_email_addresses
  }
  depends_on = [aws_sns_topic_subscription.sns_subscription]
}

resource "aws_sns_topic" "user_updates" {
  name = "sns_budget_topic"
}

# Creation for SNS Topic Subscription
resource "aws_sns_topic_subscription" "sns_subscription" {
  count                  = var.sns_topic_enable == 1 ? 1 : 0
  topic_arn              = aws_sns_topic.user_updates.arn
  protocol               = var.protocol[count.index]
  endpoint               = var.endpoint[count.index]
  endpoint_auto_confirms = true
}

output "subscription_arn" {
  value = aws_sns_topic_subscription.sns_subscription.0.arn
}

# Create IAM policy to allow publishing to SNS topics
resource "aws_iam_policy" "budget_sns_publish_policy" {
  name        = "budget-sns-publish-policy"
  description = "Policy to allow AWS Budgets to publish messages to SNS topics"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = aws_sns_topic.user_updates.arn
      }
    ]
  })
}

# Attach the policy to the IAM role used by AWS Budgets
resource "aws_iam_role_policy_attachment" "budget_sns_publish_attachment" {
  role       = aws_iam_role.budget_iam_role.name # Replace with the name of the IAM role used by AWS Budgets
  policy_arn = aws_iam_policy.budget_sns_publish_policy.arn
}

resource "aws_iam_role" "budget_iam_role" {
  name = "budget_iam_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "budgets.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

/*


resource "aws_budgets_budget" "ec2" {
  for_each     = var.budget_name
  name         = each.value.name
  budget_type  = each.value.budget_type
  limit_amount = each.value.limit_amount
  limit_unit   = each.value.limit_unit
  time_unit    = each.value.time_unit


  notification {
    comparison_operator        = each.value.comparison_operator
    threshold                  = each.value.threshold
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_sns_topic_arns  = [aws_sns_topic.user_updates.arn]
    subscriber_email_addresses = var.subscriber_email_addresses
  }
  depends_on = [aws_sns_topic_subscription.sns_subscription]
}
*/