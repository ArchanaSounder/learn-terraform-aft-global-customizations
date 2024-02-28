# Creates security hub admin account
resource "aws_securityhub_organization_configuration" "org_config" {
  count                 = var.securityhub_org_config_enable == 1 ? 1 : 0
  auto_enable           = var.auto_enable
  auto_enable_standards = var.auto_enable_standards
}

