# Variable declaration for protocol
variable "protocol" {
  type = string
}
# Variable declaration for endpoint
variable "endpoint" {
  type = string
}
# Variable declaration for topic arn
variable "topic_arn" {
  type = string
}
# Enable/Disable sns topic 
variable "sns_topic_enable" {
  default = 1
}
