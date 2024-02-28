# Name for the security hub enable default standards
variable "enable_default_standards" {
  default = true
}

# Enable/Disable security hub enable controls
variable "auto_enable_controls" {
  default = true
}

# Variable declaration for admin account id
variable "admin_account_id" {
  type = list(string)
}

# Variable declaration for admin account id
variable "audit_admin_account_id" {

}
# Variable declaration for log account id
variable "logging_admin_account_id" {

}
# Variable declaration for aft account id
variable "aft_admin_account_id" {

}


# Variable declaration for enabling standards for all new accounts
variable "auto_enable_standards" {
  default = "DEFAULT"
}

# Variable declaration to auto enable for all new accounts
variable "auto_enable" {
  default = true
}
# Variable declaration for display_name
variable "display_name" {

}
# Variable declaration for group_name
variable "description" {
  default = "enable sso group"
}

variable "user_name" {

}

variable "given_name" {

}

variable "family_name" {

}

variable "email_id" {

}
variable "display_name_group" {

}

variable "control_name" {

}

variable "guardduty_enabler" {
  description = "Guardduty enable or disable"
  default     = true
}
variable "auto_enable_organization_members" {
  default = "ALL"
}

variable "detector_id" {
  type    = string
  default = "dec6afa9d477d76ab849411a83b42c9d"
}

variable "s3_logs_auto_enable" {
  default = true
}

variable "kubernetes_audit_logs_enable" {
  default = false
}

variable "ebs_volumes_enable" {
  default = false
}
variable "guard_duty_admin_account_enable" {
  default = 1
}

variable "sso_groups" {
  description = "A map of AWS SSO groups"
  type = map(object({
    description = optional(string)
  }))
}

variable "default_region" {
  default = "Mumbai"
}

variable "sso_users" {
  description = "A map of AWS SSO users"
  type = map(object({
    display_name       = string
    given_name         = string
    family_name        = string
    sso_groups         = list(string)
    locale             = optional(string)
    nickname           = optional(string)
    preferred_language = optional(string)
    profile_url        = optional(string)
    timezone           = optional(string)
    title              = optional(string)
    user_type          = optional(string)
    emails = optional(list(object({
      value   = optional(string)
      primary = optional(bool, true)
      type    = optional(string)
    })), [])

  }))
}
variable "group_id" {
  type    = list(any)
  default = ["21e34d7a-70c1-702b-12dc-38e542150582"]
}

variable "conformance_packs" {
  description = "List of conformance packs to apply to AWS Organization accounts"
  type = list(object({
    name = string
    inputs_parameters = optional(list(object({
      name  = string
      value = string
    })))
    template_body   = optional(string)
    template_s3_uri = optional(string)
  }))
  default = []
}
variable "tags" {
  type        = map(string)
  description = "Map of tags"
}
variable "s3_bucket_name" {
  type = map(any)
  default = {
    lanfig = {
      bucket_name   = "aws-config-log-landig"
      force_destroy = "false"
      object_lock   = "false"

    }
  }
}
variable "s3_bucket_name_config" {
  default = ["aws-config-log"]
}
variable "control_tower_account_ids" {
  type = object({
    audit   = string
    logging = string
  })
  description = "Control Tower core account IDs"
}

variable "gd_delegated_admin_acc_id" {
  description = "The account id of the delegated admin."
}

variable "sh_delegated_admin_acc_id" {
  description = "The account id of the delegated admin."
  default     = "822875349860"
}


variable "gd_finding_publishing_frequency" {
  description = "Specifies the frequency of notifications sent for subsequent finding occurrences."
  default     = "SIX_HOURS"
}

variable "enabled" {
  description = "The boolean flag whether this module is enabled or not. No resources are created when set to false."
  default     = true
}

variable "assume_role_name" {

}

variable "budget_type" {
  default = "COST"
}

variable "budget_name" {
  default = "master_account_budget"
}

variable "limit_amount" {
  default = "100"
}

variable "limit_unit" {
  default = "USD"
}

variable "time_unit" {
  default = "MONTHLY"
}
/*
variable subscriber_email_addresses {
    type = list(string)
    default = ["archana@cloud-kinetics.com"]
}
*/
variable "protocol" {
  default = ["email"]
}
variable "endpoint" {
  type    = list(string)
  default = ["archana@cloud-kinetics.com"]
}
variable "subscriber_email_addresses" {
  type    = list(string)
  default = ["Hussain.champeli@cloud-kinetics.com"]
}


variable "org_tag_policy_name" {
  type    = string
  default = "orgtagpolicy"
}
variable "org_tag_policy_description" {
  type    = string
  default = "tagging policy"
}

variable "org_tag_policy_type" {
  type    = string
  default = "TAG_POLICY"
}

variable "emailAddress" {
  type        = list(any)
  description = "Enter the email address to subscribe to the SNS notification"
  default     = ["archana@cloud-kinetics.com"]
}

variable "account_ids" {

}

variable "conformance-pack-excluded-accounts" {

}

variable "minimum_password_length" {
  type    = number
  default = 8
}

variable "require_lowercase_characters" {
  default = true
}

variable "require_numbers" {
  default = true
}

variable "require_uppercase_characters" {
  default = true
}

variable "require_symbols" {
  default = true
}
variable "allow_users_to_change_password" {
  default = true
}

variable "max_password_age" {
  default = 90
}