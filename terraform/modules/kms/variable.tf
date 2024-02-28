# Variable declaration for deletion_window_in_days
variable "deletion_window_in_days" {
  default = 30
}

# Variable declaration for kms key count
variable "kms_key_count" {
  default = 1
}

# Variable declaration for kms key usage
variable "key_usage" {
  default = "ENCRYPT_DECRYPT"
  type    = string
}

# Variable declaration for customer_master_key_spec
variable "customer_master_key_spec" {
  type    = string
  default = "SYMMETRIC_DEFAULT"
}

# Variable declaration for enable_key_rotation
variable "enable_key_rotation" {
  default = false
}
variable "default_region" {

}
# Variable declaration for multi_region
variable "multi_region" {
  default = false
}
# Variable declaration for multi_region
variable "is_enabled" {
  default = true
}
variable "delegated_admin_acc_id" {

}

variable "assume_role_name" {

}