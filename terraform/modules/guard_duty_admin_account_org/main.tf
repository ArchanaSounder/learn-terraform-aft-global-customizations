#Provides a resource to manage an Amazon GuardDuty detector
resource "aws_guardduty_organization_admin_account" "guard_duty_admin_acc" {
  count            = var.guard_duty_admin_account_enable == 1 ? 1 : 0
  admin_account_id = var.admin_account_id[count.index]
}