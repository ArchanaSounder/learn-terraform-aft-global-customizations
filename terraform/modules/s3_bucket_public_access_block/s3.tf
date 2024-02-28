
resource "aws_s3_bucket_public_access_block" "bucket_public_access_block" {
  count                   = var.bucket_public_access_enable == 1 ? 1 : 0
  bucket                  = var.bucket_id
  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}




