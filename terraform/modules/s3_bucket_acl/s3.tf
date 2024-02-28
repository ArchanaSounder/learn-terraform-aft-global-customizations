# Resource creation for bucket acl
resource "aws_s3_bucket_acl" "bucket_acl" {
  count  = var.bucket_acl_enable == 1 ? 1 : 0
  bucket = var.bucket_id
  acl    = var.acl
}





