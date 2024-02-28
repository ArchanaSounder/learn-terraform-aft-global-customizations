output "group_id" {
  value = aws_identitystore_group.sso_group.*.group_id
}