variable budget_type {
  default = "COST"
}

variable budget_name {
  default = "master_account_budget"
}

variable limit_amount {
  default = "100"
}

variable limit_unit {
  default = "USD"
}

variable time_unit {
  default = "MONTHLY"
}

variable subscriber_email_addresses {
  type    = list(string)
  default = ["Hussain.champeli@cloud-kinetics.com"]
}

variable protocol {
  default = ["email"]
}

variable endpoint {
  type    = list(string)
  default = ["archana@cloud-kinetics.com"]
}

variable sns_topic_enable {
  default = 1
}

variable bucket_comparison_operator {
 default = "GREATER_THAN"

}

variable bucket_threshold_type {
default = "PERCENTAGE"
}

variable budget_threshold {
default = 100
}

variable budget_notification_type {
default = "FORECASTED"
}
