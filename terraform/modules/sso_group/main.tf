data "aws_ssoadmin_instances" "sso_group" {}

resource "aws_identitystore_group" "sso_group" {
  count             = var.sso_group_enable == 1 ? length(var.display_name) : 0
  display_name      = var.display_name[count.index]
  description       = var.description
  identity_store_id = tolist(data.aws_ssoadmin_instances.sso_group.identity_store_ids)[0]
}