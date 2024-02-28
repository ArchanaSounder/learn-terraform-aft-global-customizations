#Enables Security hub for the resources
resource "aws_securityhub_account" "security_hub" {
  enable_default_standards = var.enable_default_standards
  auto_enable_controls     = var.auto_enable_controls
}

