


resource "aws_config_organization_conformance_pack" "config-conformance-pack" {
  for_each = { for pack in local.conformance_packs : pack.name => pack }
  name     = each.value.name
  dynamic "input_parameter" {
    for_each = each.value.input_parameters != null ? each.value.input_parameters : {}
    content {
      parameter_name  = input_parameter.value.name
      parameter_value = input_parameter.value.value
    }
  }
  template_body     = file(each.value.template_body_file)
  excluded_accounts = [var.conformance-pack-excluded-accounts,"767397908688"]
}

locals {
  conformance_packs = [
    {
      name               = "ConformancePack1"
      template_body_file = "${path.module}/files/AWS-Control-Tower-Detective-Guardrails.yaml"
      input_parameters = {
        example_param1 = {
          name  = "RestrictedIncomingTrafficParamBlockedPort1"
          value = "18"
        }
      }
    },
    {
      name               = "ConformancePack2"
      template_body_file = "${path.module}/files/Security-Best-Practices-for-Secrets-Manager.yaml"
      input_parameters   = null
    }

    # Add more conformance packs as needed
  ]
}


