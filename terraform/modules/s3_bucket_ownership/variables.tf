variable "bucket_id" {

}

variable "object_ownership" {
  description = "Object ownership. Valid values: BucketOwnerPreferred, ObjectWriter or BucketOwnerEnforced"
  default     = "BucketOwnerPreferred"
}

variable "bucket_ownership_enable" {
  default = 1
}
