resource "aws_s3_bucket" "s3_bucket" {
  for_each = var.s3_bucket_name
  #{ for idx, name in var.s3_bucket_name : idx => name }
  bucket              = local.aws_gd_s3_name
  force_destroy       = each.value.force_destroy
  object_lock_enabled = each.value.object_lock
}
resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  depends_on = [aws_s3_bucket.s3_bucket]
  bucket     = var.bucket_id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_id
      sse_algorithm     = "aws:kms"
    }
  }
}
resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  for_each   = aws_s3_bucket.s3_bucket
  bucket     = each.value.id
  policy     = data.aws_iam_policy_document.bucket_pol[each.key].json
  depends_on = [aws_s3_bucket.s3_bucket]
}

locals {
  aws_gd_s3_name = coalesce(
    var.aws_config.delivery_channel_s3_bucket_name,
    "aws-gdy-config-news-${var.control_tower_account_ids.logging}-${data.aws_region.current.name}"
  )
}
/*
data "aws_iam_policy_document" "aws_config_s3" {
  statement {
    sid       = "AWSConfigBucketPermissionsCheck"
    actions   = ["s3:GetBucketAcl", "s3:PutBucketAcl"]
    resources = ["arn:aws:s3:::${local.aws_gd_s3_name}"]

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com","guardduty.amazonaws.com"]
    }
  }
    statement {
    sid       = "AWSConfigBucketPermissionsput"
    actions   = ["s3:PutBucketAcl"]
    resources = ["arn:aws:s3:::${local.aws_gd_s3_name}"]

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com","guardduty.amazonaws.com"]
    }
  }

  statement {
    sid       = "AWSConfigBucketExistenceCheck"
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${local.aws_gd_s3_name}"]

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com","guardduty.amazonaws.com"]
    }
  }

  statement {
    sid       = "AllowConfigWriteAccess"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${local.aws_gd_s3_name}/*"]

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com","guardduty.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}
*/
data "aws_region" "current" {}

# GD Findings Bucket policy
data "aws_iam_policy_document" "bucket_pol" {
  for_each = aws_s3_bucket.s3_bucket
  statement {
    sid = "Allow PutObject"
    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${each.value.arn}/*"
    ]

    principals {
      type        = "Service"
      identifiers = ["guardduty.amazonaws.com"]
    }
  }

  statement {
    sid = "AWSBucketPermissionsCheck"
    actions = [
      "s3:GetBucketLocation",
      "s3:GetBucketAcl",
      "s3:ListBucket"
    ]

    resources = [
      each.value.arn
    ]

    principals {
      type        = "Service"
      identifiers = ["guardduty.amazonaws.com"]
    }
  }

  statement {
    sid    = "Deny unencrypted object uploads. This is optional"
    effect = "Deny"
    principals {
      type        = "Service"
      identifiers = ["guardduty.amazonaws.com"]
    }
    actions = [
      "s3:PutObject"
    ]
    resources = [
      "${each.value.arn}/*"
    ]
    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"

      values = [
        "aws:kms"
      ]
    }
  }

  statement {
    sid    = "Deny incorrect encryption header. This is optional"
    effect = "Deny"
    principals {
      type        = "Service"
      identifiers = ["guardduty.amazonaws.com"]
    }
    actions = [
      "s3:PutObject"
    ]
    resources = [
      "${each.value.arn}/*"
    ]
    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption-aws-kms-key-id"

      values = [
        var.kms_key_arn
      ]
    }
  }

  statement {
    sid    = "Deny non-HTTPS access"
    effect = "Deny"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "s3:*"
    ]
    resources = [
      "${each.value.arn}/*"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"

      values = [
        "false"
      ]
    }
  }

  statement {
    sid    = "Access logs ACL check"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
    actions = [
      "s3:GetBucketAcl"
    ]
    resources = [
      each.value.arn
    ]
  }

  statement {
    sid    = "Access logs write"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
    actions = [
      "s3:PutObject"
    ]
    resources = [
      each.value.arn,
      "${each.value.arn}/AWSLogs/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"

      values = [
        "bucket-owner-full-control"
      ]
    }
  }
}




/*

data "aws_iam_policy_document" "bucket_pol" {
  statement {
    sid       = "Deny non-HTTPS access"
    effect    = "Deny"
    actions   = ["s3:*"]
    resources = ["arn:aws:s3:::aws-gdy-config-news-763086288388-ap-south-1/*"]

    principals {
      type        = "Service"
      identifiers = ["guardduty.amazonaws.com"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

  statement {
    sid       = "Deny incorrect encryption header"
    effect    = "Deny"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::aws-gdy-config-news-763086288388-ap-south-1/*"]

    principals {
      type        = "Service"
      identifiers = ["guardduty.amazonaws.com"]
    }

    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption-aws-kms-key-id"
      values   = ["arn:aws:kms:ap-south-1:763086288388:key/b0b2dffe-5f5b-41f5-8de7-a21894c04923"]
    }
  }

  statement {
    sid       = "Deny unencrypted object uploads"
    effect    = "Deny"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::aws-gdy-config-news-763086288388-ap-south-1/*"]

    principals {
      type        = "Service"
      identifiers = ["guardduty.amazonaws.com"]
    }

    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["aws:kms"]
    }
  }

  statement {
    sid       = "Allow PutObject"
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::aws-gdy-config-news-763086288388-ap-south-1/*"]

    principals {
      type        = "Service"
      identifiers = ["guardduty.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:aws:guardduty:ap-south-1:157483060337:detector/62c6afa9dce1e8237a4e57e3bad78056"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = ["157483060337"]
    }
  }

  statement {
    sid       = "Allow GetBucketLocation"
    effect    = "Allow"
    actions   = ["s3:GetBucketLocation"]
    resources = ["arn:aws:s3:::aws-gdy-config-news-763086288388-ap-south-1"]

    principals {
      type        = "Service"
      identifiers = ["guardduty.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:aws:guardduty:ap-south-1:157483060337:detector/62c6afa9dce1e8237a4e57e3bad78056"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = ["157483060337"]
    }
  }
}
*/