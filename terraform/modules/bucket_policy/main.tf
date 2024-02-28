# s3 bucket policy to allow access for another account
resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = var.bucket_id.landing_zone_bucket
  policy = data.aws_iam_policy_document.allow_access_from_another_account.json
}

# Iam policy document 
data "aws_iam_policy_document" "allow_access_from_another_account" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutBucketAcl",
    ]

    resources = [
      var.bucket_arn,
      "${var.bucket_arn}/*",
    ]
  }
}