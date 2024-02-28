variable "bucket_acl_enable" {
  default = 1
}

variable "bucket_id" {

}

variable "acl" {
  description = "ACL: Valid Values: private, public-read, public-read-write, authenticated-read, aws-exec-read, log-delivery-write"
  default     = "log-delivery-write"
}

