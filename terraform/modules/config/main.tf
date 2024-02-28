locals {
  aws_config_aggregators = flatten([
    for account in toset(try(var.aws_config.aggregator_account_ids, [])) : [
      for region in toset(try(var.aws_config.aggregator_regions, [])) : {
        account_id = account
        region     = region
      }
    ]
  ])
  aws_config_rules = setunion(
    try(var.aws_config.rule_identifiers, []),
    [
      "CLOUD_TRAIL_ENABLED",
      "ENCRYPTED_VOLUMES",
      "ROOT_ACCOUNT_MFA_ENABLED",
      "S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED"
    ]
  )
}

data "aws_region" "current" {}

data "aws_sns_topic" "all_config_notifications" {
  provider = aws.audit-account

  name = "aws-controltower-AllConfigNotifications"
}
data "aws_organizations_organization" "default" {}

/*
resource "aws_config_aggregate_authorization" "master" {
  for_each = { for aggregator in local.aws_config_aggregators : "${aggregator.account_id}-${aggregator.region}" => aggregator if aggregator.account_id != var.control_tower_account_ids.audit }

  account_id = each.value.account_id
  region     = each.value.region
  tags       = var.tags
}

resource "aws_config_aggregate_authorization" "master_to_audit" {
  for_each = toset(coalescelist(var.aws_config.aggregator_regions, [data.aws_region.current.name]))

  account_id = var.control_tower_account_ids.audit
  region     = each.value
  tags       = var.tags
}
*/
resource "aws_iam_role" "config_recorder" {
  name = "LandingZone-ConfigRecorderRole"
  path = var.path
  tags = var.tags

  assume_role_policy = templatefile("${path.module}/iam/service_assume_role.json.tpl", {
    service = "config.amazonaws.com"
  })
  provider = aws.audit-account
}

resource "aws_iam_role_policy_attachment" "config_recorder_config_role" {
  role       = aws_iam_role.config_recorder.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
  provider   = aws.audit-account
}

resource "aws_config_configuration_recorder" "default" {
  name     = "default"
  role_arn = aws_iam_role.config_recorder.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
  provider = aws.audit-account
}
resource "aws_config_configuration_recorder_status" "default" {
  name       = aws_config_configuration_recorder.default.name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.default]
  provider   = aws.audit-account
}


resource "aws_config_delivery_channel" "default" {
  name           = "default"
  s3_bucket_name = "aws-controltower-logs-763086288388-ap-south-1"
  s3_key_prefix  = "o-avemv5ns8z"
  #s3_kms_key_arn = ""
  sns_topic_arn = data.aws_sns_topic.all_config_notifications.arn

  snapshot_delivery_properties {
    delivery_frequency = var.aws_config.delivery_frequency
  }

  depends_on = [aws_config_configuration_recorder.default]
  provider   = aws.audit-account
}

resource "aws_config_organization_managed_rule" "default" {
  provider = aws.audit-account
  for_each = toset(local.aws_config_rules)

  name            = each.value
  rule_identifier = each.value
  depends_on      = [aws_config_configuration_recorder.default]
}

// AWS Config - Audit account configuration
resource "aws_config_configuration_aggregator" "audit" {
  provider = aws.audit-account

  name = "audit"
  tags = var.tags

  account_aggregation_source {
    account_ids = [
      for account in data.aws_organizations_organization.default.accounts : account.id if account.id != var.control_tower_account_ids.audit
    ]
    all_regions = true
  }
}

resource "aws_config_aggregate_authorization" "audit" {
  for_each = { for aggregator in local.aws_config_aggregators : "${aggregator.account_id}-${aggregator.region}" => aggregator if aggregator.account_id != var.control_tower_account_ids.audit }
  provider = aws.audit-account

  account_id = each.value.account_id
  region     = each.value.region
  tags       = var.tags
}

resource "aws_sns_topic_subscription" "aws_config" {
  for_each = var.aws_config_sns_subscription
  provider = aws.audit-account

  endpoint               = each.value.endpoint
  endpoint_auto_confirms = length(regexall("http", each.value.protocol)) > 0
  protocol               = each.value.protocol
  topic_arn              = "arn:aws:sns:${data.aws_region.current.name}:${var.control_tower_account_ids.audit}:aws-controltower-AggregateSecurityNotifications"
}
/*
// AWS Config - Logging account configuration
resource "aws_config_aggregate_authorization" "logging" {
  for_each = { for aggregator in local.aws_config_aggregators : "${aggregator.account_id}-${aggregator.region}" => aggregator if aggregator.account_id != var.control_tower_account_ids.audit }
  provider = aws.logging

  account_id = each.value.account_id
  region     = each.value.region
  tags       = var.tags
}
*/
