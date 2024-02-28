# Variable declaration for sns topic name
variable "sns_topic_name" {
  type = string
}

# Enable/Disable sns topic 
variable "sns_topic_enable" {
  default = 1
}
