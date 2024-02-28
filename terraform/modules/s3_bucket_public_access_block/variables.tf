variable "bucket_id" {

}

variable "bucket_public_access_enable" {
  default = 1
}


variable "block_public_acls" {
  default = true
}

variable "block_public_policy" {
  default = true
}

variable "ignore_public_acls" {
  default = true
}

variable "restrict_public_buckets" {
  default = true
}


