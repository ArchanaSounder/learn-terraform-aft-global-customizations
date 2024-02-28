/*output "groups" {
  description = "All attributes of the newly created AWS SSO groups in the identity store."
  value       = data.aws_identitystore_group.group
}
*/

output "users" {
  description = "All attributes of the newly created AWS SSO users in the identity store."
  value       = aws_identitystore_user.user
}