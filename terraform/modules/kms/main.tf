# Creation of kms key resource
resource "aws_kms_key" "kms_key" {
  count                    = var.kms_key_count == 1 ? 1 : 0
  deletion_window_in_days  = var.deletion_window_in_days
  key_usage                = var.key_usage
  customer_master_key_spec = var.customer_master_key_spec
  enable_key_rotation      = var.enable_key_rotation
  multi_region             = var.multi_region
  policy                   = data.aws_iam_policy_document.kms_pol.json #file("kms_policy.json")
  is_enabled               = var.is_enabled
}
/*
# GD Findings bucket KMS CMK policy
data "aws_iam_policy_document" "kms_pol" {

  statement {
    sid = "Allow use of the key for guardduty"
    actions = [
      "kms:GenerateDataKey*",
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:DescribeKey"
    ]

    resources = [
      "arn:aws:kms:${var.default_region}:${var.delegated_admin_acc_id}:key/*"
    ]

    principals {
      type        = "Service"
      identifiers = ["guardduty.amazonaws.com"]
    }
  }

  statement {
    sid = "Allow attachment of persistent resources for guardduty"
    actions = [
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant"
    ]

    resources = [
      "arn:aws:kms:${var.default_region}:${var.delegated_admin_acc_id}:key/*"
    ]

    principals {
      type        = "Service"
      identifiers = ["guardduty.amazonaws.com"]
    }

    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"

      values = [
        "true"
      ]
    }
  }

  statement {
    sid = "Allow all KMS Permissions for root account of GD Admin"
    actions = [
      "kms:*"
    ]

    resources = [
      "arn:aws:kms:${var.default_region}:${var.delegated_admin_acc_id}:key/*"
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.delegated_admin_acc_id}:root"]
    }
  }

  statement {
    sid = "Allow access for Key Administrators"
    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:TagResource",
      "kms:UntagResource",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion"
    ]

    resources = [
      "*"
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.delegated_admin_acc_id}:role/${var.assume_role_name}"]
    }
  }
}
*/



  # GD Findings bucket KMS CMK policy
data "aws_iam_policy_document" "kms_pol" {

  statement {
    sid = "Allow use of the key for guardduty"
    actions = [
      "kms:GenerateDataKey*",
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:DescribeKey"
    ]

    resources = [
      "arn:aws:kms:${data.aws_region.current.name}:${var.delegated_admin_acc_id}:key/*"
    ]

    principals {
      type        = "Service"
      identifiers = ["guardduty.amazonaws.com"]
    }
  }

  statement {
    sid = "Allow attachment of persistent resources for guardduty"
    actions = [
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant"
    ]

    resources = [
      "arn:aws:kms:${data.aws_region.current.name}:${var.delegated_admin_acc_id}:key/*"
    ]

    principals {
      type        = "Service"
      identifiers = ["guardduty.amazonaws.com"]
    }

    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"

      values = [
        "true"
      ]
    }
  }

  statement {
    sid = "Allow all KMS Permissions for root account of GD Admin"
    actions = [
      "kms:*"
    ]

    resources = [
      "arn:aws:kms:${data.aws_region.current.name}:${var.delegated_admin_acc_id}:key/*"
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.delegated_admin_acc_id}:root"]
    }
  }

  statement {
    sid = "Allow access for Key Administrators"
    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:TagResource",
      "kms:UntagResource",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion"
    ]

    resources = [
      "*"
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.delegated_admin_acc_id}:role/${var.assume_role_name}"]
    }
  }
}

data "aws_region" "current" {}
