data "aws_ssoadmin_instances" "store_id" {}

locals {
  group_membership = flatten([
    for user_name, user_attr in var.sso_users : [
      for group_name in user_attr.sso_groups : {
        user_name  = user_name
        group_name = group_name
      }
    ]
  ])

}

resource "aws_identitystore_group_membership" "group_membership" {
  for_each = { for pair in local.group_membership : "${pair.user_name}.${pair.group_name}" => pair }

  identity_store_id = tolist(data.aws_ssoadmin_instances.store_id.identity_store_ids)[0]
  group_id          = var.group_id[0] #data.aws_identitystore_group.group[each.value.group_name].group_id
  member_id         = aws_identitystore_user.user[each.value.user_name].user_id
}
/*
resource "aws_identitystore_group" "group" {
  for_each = var.sso_groups

  identity_store_id = tolist(data.aws_ssoadmin_instances.store_id.identity_store_ids)[0]
  display_name      = each.key
  description       = lookup(each.value, "description", null)
}

data "aws_identitystore_group" "group" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.store_id.identity_store_ids)[0]
   for_each = var.sso_groups
  alternate_identifier {
    unique_attribute {
      attribute_path  = each.key
      attribute_value = each.key
    }
  }
}
*/


resource "aws_identitystore_user" "user" {
  for_each = var.sso_users

  identity_store_id = tolist(data.aws_ssoadmin_instances.store_id.identity_store_ids)[0]
  user_name         = each.key
  display_name      = each.value.display_name

  locale             = lookup(each.value, "locale", null)
  nickname           = lookup(each.value, "nickname", null)
  preferred_language = lookup(each.value, "preferred_language", null)
  profile_url        = lookup(each.value, "profile_url", null)
  timezone           = lookup(each.value, "timezone", null)
  title              = lookup(each.value, "title", null)
  user_type          = lookup(each.value, "user_type", null)

  name {
    given_name       = each.value.given_name
    family_name      = each.value.family_name
    formatted        = lookup(each.value, "formatted", null)
    honorific_prefix = lookup(each.value, "honorific_prefix", null)
    honorific_suffix = lookup(each.value, "honorific_suffix", null)
    middle_name      = lookup(each.value, "middle_name", null)
  }

  dynamic "emails" {
    for_each = each.value.emails
    content {
      value   = lookup(emails.value, "value", null)
      primary = lookup(emails.value, "primary", null)
      type    = lookup(emails.value, "type", null)
    }
  }
}