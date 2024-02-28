output "bucket_ids" {
  value = {
    for value, bucket in aws_s3_bucket.s3_bucket : value => bucket.id
  }
}
output "bucket_arn" {
  value = {
    for value, bucket in aws_s3_bucket.s3_bucket : value => bucket.arn
  }
}

output "bucket_name" {
  value = {
    for value, bucket in aws_s3_bucket.s3_bucket : value => bucket.bucket
  }
}