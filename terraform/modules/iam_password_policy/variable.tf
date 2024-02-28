variable "minimum_password_length" {
  type    = number
  default = 8
}

variable "require_lowercase_characters" {
  default = true
}

variable "require_numbers" {
  default = true
}

variable "require_uppercase_characters" {
  default = true
}

variable "require_symbols" {
  default = true
}
variable "allow_users_to_change_password" {
  default = true
}

variable "max_password_age" {
  default = 90
}