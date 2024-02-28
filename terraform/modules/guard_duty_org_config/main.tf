#Provides a resource to manage an Amazon GuardDuty detector
resource "aws_guardduty_organization_configuration" "guard_duty_config" {
  auto_enable_organization_members = var.auto_enable_organization_members
  detector_id                      = var.detector_id
  depends_on                       = [aws_guardduty_organization_admin_account.guard_duty_admin_acc]
  datasources {
    s3_logs {
      auto_enable = var.s3_logs_auto_enable
    }
    kubernetes {
      audit_logs {
        enable = var.kubernetes_audit_logs_enable
      }
    }
    malware_protection {
      scan_ec2_instance_with_findings {
        ebs_volumes {
          auto_enable = var.ebs_volumes_enable
        }
      }
    }
  }
  provider = aws.audit-account
  lifecycle {
    ignore_changes = [
      datasources
    ]
  }
}

resource "aws_guardduty_organization_configuration_feature" "eks_runtime_monitoring" {
  detector_id = var.detector_id
  name        = "EBS_MALWARE_PROTECTION"
  auto_enable = "NEW"
  provider    = aws.audit-account
  depends_on  = [aws_guardduty_organization_configuration.guard_duty_config]
}
data "aws_organizations_organization" "default" {}
/*
locals {
  mem_accounts = data.aws_organizations_organization.default.accounts
  deleg_admin  = var.gd_delegated_admin_acc_id
  temp = [
    for x in local.mem_accounts :
    x if x.id != local.deleg_admin && x.status == "ACTIVE"
  ]
}
*/

/*
#Provides a resource to manage an Amazon GuardDuty detector
resource "aws_guardduty_detector" "guardduty_detector" {
  enable                       = var.enabled
  finding_publishing_frequency = var.gd_finding_publishing_frequency
  provider                     = aws.audit-account
}
*/
data "aws_guardduty_detector" "audit-account" {
  provider = aws.audit-account
}


#Provides a resource to manage an Amazon GuardDuty detector
resource "aws_guardduty_organization_admin_account" "guard_duty_admin_acc" {
  count            = var.guard_duty_admin_account_enable == 1 ? 1 : 0
  admin_account_id = var.admin_account_id[count.index]

}

# GuardDuty Publishing destination in the Delegated admin account
resource "aws_guardduty_publishing_destination" "pub_dest" {
  count           = var.enabled ? 1 : 0
  detector_id     = data.aws_guardduty_detector.audit-account.id
  destination_arn = var.gd_publishing_dest_bucket_arn
  kms_key_arn     = var.gd_kms_key_arn
  depends_on      = [aws_guardduty_organization_admin_account.guard_duty_admin_acc]
  provider        = aws.audit-account
}



data "aws_organizations_organization" "current" {}








locals {
  mem_accounts = var.gd_my_org.accounts
  deleg_admin  = var.gd_delegated_admin_acc_id
  temp = [
    for x in local.mem_accounts :
    x if x.id != local.deleg_admin && x.status == "ACTIVE"
  ]
  member_accounts = length(local.temp)
}


resource "aws_guardduty_member" "members" {
  count = local.member_accounts

  provider = aws.audit-account

  detector_id = var.detector_id
  account_id  = local.temp[count.index].id
  email       = local.temp[count.index].email
  invite      = true
  depends_on  = [aws_guardduty_organization_admin_account.guard_duty_admin_acc]
  lifecycle {
    ignore_changes = [
      email
    ]
  }
}

