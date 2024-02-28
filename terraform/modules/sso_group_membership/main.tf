data "aws_ssoadmin_instances" "sso_group_mem" {}

resource "aws_identitystore_group_membership" "example" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.sso_group_mem.identity_store_ids)[0]
  group_id          = var.group_id
  member_id         = var.user_id
}