# Variable declaration for replica key
variable "replication_description" {
  default = "Landing replica key"
}
variable "replication_deletion_window_in_days" {
  default = 30
}
variable "primary_key_arn" {
  type    = list(string)
  default = ["arn:aws:kms:ap-south-1:822875349860:key/1e25d247-f8f0-4118-be8b-1cf1b9c316c7"]
}
variable "replication_enable" {
  default = true
}
