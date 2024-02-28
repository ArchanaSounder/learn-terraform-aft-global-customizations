
resource "aws_s3_bucket_ownership_controls" "bucket_ownership_controls" {
  count  = var.bucket_ownership_enable == 1 ? 1 : 0
  bucket = var.bucket_id
  rule {
    object_ownership = var.object_ownership
  }
}






