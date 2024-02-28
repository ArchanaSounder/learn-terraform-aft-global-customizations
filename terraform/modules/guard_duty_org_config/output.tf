output "guardduty_enabler_id" {
  value = aws_guardduty_organization_admin_account.guard_duty_admin_acc.*.id
}
