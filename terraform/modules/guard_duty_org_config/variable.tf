variable "auto_enable_organization_members" {
  default = "NEW"
}

variable "detector_id" {
  type    = string
  default = "30c6578cdad025c8613ae20a7efce0f4"
}

variable "s3_logs_auto_enable" {
  default = true
}

variable "kubernetes_audit_logs_enable" {
  default = false
}

variable "ebs_volumes_enable" {
  default = true
}
variable "gd_delegated_admin_acc_id" {
  description = "The account id of the delegated admin."
}

variable "gd_finding_publishing_frequency" {
  description = "Specifies the frequency of notifications sent for subsequent finding occurrences."
  default     = "SIX_HOURS"
}
variable "gd_publishing_dest_bucket_arn" {
  description = "The bucket ARN to publish GD findings"
}

variable "gd_kms_key_arn" {
  description = "The KMS key to encrypt GD findings in the S3 bucket"
}
variable "enabled" {
  description = "The boolean flag whether this module is enabled or not. No resources are created when set to false."
  default     = true
}
variable "guard_duty_admin_account_enable" {
  default = 1
}

variable "admin_account_id" {
  type    = list(any)
  default = ["822875349860"]
}
variable "gd_my_org" {
  description = "The AWS Organization with all the accounts"
}

