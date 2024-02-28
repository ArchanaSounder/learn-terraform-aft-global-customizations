variable "conformance_packs" {
  description = "List of conformance packs to apply to AWS Organization accounts"
  type = list(object({
    name = string
    inputs_parameters = optional(list(object({
      name  = string
      value = string
    })))
    template_body   = optional(string)
    template_s3_uri = optional(string)
  }))
  default = []
}

variable "conformance-pack-excluded-accounts" {

}