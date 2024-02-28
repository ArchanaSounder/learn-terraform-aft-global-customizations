variable "s3_bucket_name" {
  type = map(any)

}
variable "aws_config" {
  type = object({
    aggregator_account_ids          = optional(list(string), [])
    aggregator_regions              = optional(list(string), [])
    delivery_channel_s3_bucket_name = optional(string, null)
    delivery_channel_s3_key_prefix  = optional(string, null)
    delivery_frequency              = optional(string, "TwentyFour_Hours")
    rule_identifiers                = optional(list(string), [])
  })
  default = {
    aggregator_account_ids          = []
    aggregator_regions              = []
    delivery_channel_s3_bucket_name = null
    delivery_channel_s3_key_prefix  = null
    delivery_frequency              = "TwentyFour_Hours"
    rule_identifiers                = []
  }
  description = "AWS Config settings"

  validation {
    condition     = contains(["One_Hour", "Three_Hours", "Six_Hours", "Twelve_Hours", "TwentyFour_Hours"], var.aws_config.delivery_frequency)
    error_message = "The delivery frequency must be set to \"One_Hour\", \"Three_Hours\", \"Six_Hours\", \"Twelve_Hours\", or \"TwentyFour_Hours\"."
  }
}
variable "control_tower_account_ids" {
  type = object({
    audit   = string
    logging = string
  })
  description = "Control Tower core account IDs"
}

variable "bucket_id" {

}
variable "kms_key_id" {

}
variable "kms_key_arn" {

}