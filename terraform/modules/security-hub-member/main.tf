locals {
  mem_accounts = var.sh_my_org.accounts
  deleg_admin  = var.sh_delegated_admin_acc_id
  temp = [
    for x in local.mem_accounts :
    x if x.id != local.deleg_admin && x.status == "ACTIVE"
  ]
  member_accounts = length(local.temp)
}




resource "aws_securityhub_member" "security_member" {
  count      = local.member_accounts
  account_id = local.temp[count.index].id
  email      = local.temp[count.index].email
  invite     = false
  lifecycle {
    ignore_changes = [
      # AWS API says `email` is optional and is not used in organizations, so
      # not returned by the ListMembers query.
      # Terraform provider currently marks it as required which causes a diff.
      email,
      # `invite` is only to be true for non-organization members. But Terraform
      # updates it based on `member_status`
      invite,
    ]
  }
}

