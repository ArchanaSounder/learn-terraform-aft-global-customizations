resource "aws_kms_replica_key" "replica_key" {
  count                   = var.replication_enable ? length(var.primary_key_arn) : 0
  description             = var.replication_description
  deletion_window_in_days = var.replication_deletion_window_in_days
  primary_key_arn         = var.primary_key_arn[count.index]
}