#Provides a resource to manage an Amazon GuardDuty detector
resource "aws_guardduty_detector" "guardduty_detector" {
  enable = var.guardduty_enabler
}