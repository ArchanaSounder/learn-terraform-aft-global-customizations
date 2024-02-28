# Output for kms key arn
output "kms_key_arn" {
  value = aws_kms_key.kms_key.*.arn
}
# Output for kms key id
output "kms_key_id" {
  value = aws_kms_key.kms_key.*.key_id
}