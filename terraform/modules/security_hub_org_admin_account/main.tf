
# Creates security hub admin account
resource "aws_securityhub_organization_admin_account" "admin_account" {
  count            = var.securityhub_admin_account_enable == 1 ? 1 : 0
  admin_account_id = var.admin_account_id[count.index]
}
