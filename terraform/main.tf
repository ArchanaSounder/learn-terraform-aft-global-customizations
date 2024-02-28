terraform {
  required_version = ">= 0.15.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "<5.28.0"
    }

  }
}


data "aws_caller_identity" "current" {}

provider "aws" {
  /* other provider config */
  assume_role {
    // Assume the organization access role
    role_arn = "arn:aws:iam::${var.audit_admin_account_id}:role/AWSAFTExecution"
  }
  alias = "audit-account"
}

provider "aws" {
  /* other provider config */
  assume_role {
    // Assume the organization access role
    role_arn = "arn:aws:iam::${var.logging_admin_account_id}:role/AWSAFTExecution"
  }
  alias = "logging"
}

provider "aws" {
  /* other provider config */
  assume_role {
    // Assume the organization access role
    role_arn = "arn:aws:iam::${var.aft_admin_account_id}:role/AWSAFTExecution"
  }
  alias = "aft"
}



# Module declaration for security hub 
module "security_hub" {
  source                   = "./modules/security_hub"
  enable_default_standards = var.enable_default_standards
  auto_enable_controls     = var.auto_enable_controls
  providers = {
    aws = aws.audit-account
  }
}

# Module declaration for security hub organisation admin account
module "security_hub_org_admin" {
  source           = "./modules/security_hub_org_admin_account"
  admin_account_id = var.admin_account_id
  depends_on       = [module.security_hub]
}

# Module declaration for security hub organisation configuration
module "security_hub_org_config" {
  source                = "./modules/security_hub_org_config"
  auto_enable           = var.auto_enable
  auto_enable_standards = var.auto_enable_standards
  depends_on            = [module.security_hub_org_admin]
  providers = {
    aws = aws.audit-account
  }
}

module "security_hub_member" {
  source                    = "./modules/security-hub-member"
  sh_delegated_admin_acc_id = var.gd_delegated_admin_acc_id
  sh_my_org                 = data.aws_organizations_organization.org
  providers = {
    aws = aws.audit-account
  }
  depends_on = [module.security_hub_org_config]
}

module "budget" {
  source                     = "./modules/budget"
  budget_name                = var.budget_name
  budget_type                = var.budget_type
  limit_amount               = var.limit_amount
  limit_unit                 = var.limit_unit
  time_unit                  = var.time_unit
  protocol                   = var.protocol
  endpoint                   = var.endpoint
  subscriber_email_addresses = var.subscriber_email_addresses
}
output "susna" {
  value = module.budget.subscription_arn
}
#data aws_organizations_organization "org" {}
/*
module guarduty {
  source                                          = "./modules/guardduty"
  guardduty_enabler                               = var.guardduty_enabler
  
}

*/
data "aws_guardduty_detector" "audit-account" {
  provider = aws.audit-account
}

module "guarduty_org_config" {
  source                           = "./modules/guard_duty_org_config"
  auto_enable_organization_members = var.auto_enable_organization_members
  detector_id                      = data.aws_guardduty_detector.audit-account.id #"62c6afa9dce1e8237a4e57e3bad78056" module.guarduty.guardduty_enabler_id
  s3_logs_auto_enable              = var.s3_logs_auto_enable
  kubernetes_audit_logs_enable     = var.kubernetes_audit_logs_enable
  ebs_volumes_enable               = var.ebs_volumes_enable
  enabled                          = var.enabled
  gd_finding_publishing_frequency  = var.gd_finding_publishing_frequency
  guard_duty_admin_account_enable  = var.guard_duty_admin_account_enable
  admin_account_id                 = var.admin_account_id
  gd_publishing_dest_bucket_arn    = module.s3.bucket_arn.lanfig
  gd_kms_key_arn                   = module.kms.kms_key_arn[0]
  gd_delegated_admin_acc_id        = var.gd_delegated_admin_acc_id
  gd_my_org                        = data.aws_organizations_organization.org
  providers                        = { aws.audit-account = aws.audit-account, aws.logging = aws.logging }
  depends_on                       = [module.s3]
}

data "aws_organizations_organization" "org" {}


module "identity_store" {
  source     = "./modules/identity_store"
  sso_users  = var.sso_users
  sso_groups = var.sso_groups
  group_id   = var.group_id
}
/*
module "guardrails" {
  source       = "./modules/guardrails"
  control_name = var.control_name
  #ou_name                                       = var.ou_name

}
*/

#data aws_organizations_organization "org" {}

data "aws_organizations_organizational_units" "ou" {
  parent_id = data.aws_organizations_organization.org.roots[0].id
}

module "scp_root" {
  source    = "./modules/scp"
  for_each  = fileset(path.root, "./modules/policies/*.json")
  json_file = each.value
  ou_list   = [data.aws_organizations_organizational_units.ou.id]
}


/*
module config {
  source = "./modules/config"
  tags   = var.tags
  #kms_key_arn = module.kms.kms_key_arn[0]
  control_tower_account_ids = var.control_tower_account_ids
  providers = { aws.audit-account = aws.audit-account, aws.logging = aws.logging }
  depends_on = [ aws_organizations_delegated_administrator.example ]
}
*/

resource "aws_organizations_delegated_administrator" "dele-admin" {
  account_id        = "157483060337"
  service_principal = "config-multiaccountsetup.amazonaws.com"
  depends_on        = [module.security_hub_member]
}

module "conformance_packs" {
  source = "./modules/config-conformance-pack"
  providers = {
    aws = aws.audit-account
  }
  conformance-pack-excluded-accounts = data.aws_caller_identity.current.account_id
  depends_on                         = [aws_organizations_delegated_administrator.dele-admin]
}



module "kms" {
  source                 = "./modules/kms"
  assume_role_name       = var.assume_role_name
  delegated_admin_acc_id = var.logging_admin_account_id
  default_region         = var.default_region
  providers = {
    aws = aws.logging
  }
}

module "s3" {
  source                    = "./modules/s3"
  s3_bucket_name            = var.s3_bucket_name
  bucket_id                 = module.s3.bucket_ids.lanfig
  control_tower_account_ids = var.control_tower_account_ids
  kms_key_id                = module.kms.kms_key_id[0]
  kms_key_arn               = module.kms.kms_key_arn[0]
  providers = {
    aws = aws.logging
  }

}

module "s3-bucket-access" {
  source     = "./modules/s3_bucket_public_access_block"
  bucket_id  = module.s3.bucket_name.lanfig
  depends_on = [module.s3]
  providers = {
    aws = aws.logging
  }

}
module "s3-bucket-ownership" {
  source     = "./modules/s3_bucket_ownership"
  bucket_id  = module.s3.bucket_name.lanfig
  depends_on = [module.s3-bucket-access]
  providers = {
    aws = aws.logging
  }

}


module "org_tag_policy" {
  source                     = "./modules/org-tag-policy"
  org_tag_policy_name        = var.org_tag_policy_name
  org_tag_policy_description = var.org_tag_policy_description
  org_tag_policy_type        = var.org_tag_policy_type
  org_policy_target_id       = data.aws_organizations_organization.org.roots[0].id
  depends_on                 = [module.scp_root]
}

output "data" {
  value = data.aws_organizations_organization.org.roots[0].id
}

module "breakglass" {
  source       = "./modules/breakglassuser"
  emailAddress = var.emailAddress
}

module "aws_iam_account_password_policy" {
  source                         = "./modules/iam_password_policy"
  minimum_password_length        = var.minimum_password_length
  require_lowercase_characters   = var.require_lowercase_characters
  require_numbers                = var.require_numbers
  require_uppercase_characters   = var.require_uppercase_characters
  require_symbols                = var.require_symbols
  allow_users_to_change_password = var.allow_users_to_change_password
  max_password_age               = var.max_password_age
}

module "aws_iam_account_password_policy_audit" {
  source                         = "./modules/iam_password_policy"
  minimum_password_length        = var.minimum_password_length
  require_lowercase_characters   = var.require_lowercase_characters
  require_numbers                = var.require_numbers
  require_uppercase_characters   = var.require_uppercase_characters
  require_symbols                = var.require_symbols
  allow_users_to_change_password = var.allow_users_to_change_password
  max_password_age               = var.max_password_age
  providers = {
    aws = aws.audit-account
  }
}
module "aws_iam_account_password_policy_log" {
  source                         = "./modules/iam_password_policy"
  minimum_password_length        = var.minimum_password_length
  require_lowercase_characters   = var.require_lowercase_characters
  require_numbers                = var.require_numbers
  require_uppercase_characters   = var.require_uppercase_characters
  require_symbols                = var.require_symbols
  allow_users_to_change_password = var.allow_users_to_change_password
  max_password_age               = var.max_password_age
  providers = {
    aws = aws.logging
  }
}

module "aws_iam_account_password_policy_aft" {
  source                         = "./modules/iam_password_policy"
  minimum_password_length        = var.minimum_password_length
  require_lowercase_characters   = var.require_lowercase_characters
  require_numbers                = var.require_numbers
  require_uppercase_characters   = var.require_uppercase_characters
  require_symbols                = var.require_symbols
  allow_users_to_change_password = var.allow_users_to_change_password
  max_password_age               = var.max_password_age
  providers = {
    aws = aws.aft
  }
}