#Email address
variable emailAddress {
  type        = list(any)
  description = "Enter the email address to subscribe to the SNS notification"
}

# SNS topic for breakglass
variable sns_topic_breakglass {
  default = 1
}