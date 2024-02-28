data "aws_region" "current" {}

data "aws_organizations_organization" "org" {}

data "aws_organizations_organizational_units" "ou" {
  parent_id = data.aws_organizations_organization.org.roots[0].id
}

/*
resource "aws_controltower_control" "control" {
  for_each              = var.control_name
  control_identifier =   "arn:aws:controltower:${data.aws_region.current.name}::control/${join("_", each.value.name)}"
    #for x in var.control_name : x.name == each.value.name][0]}" #"arn:aws:controltower:${data.aws_region.current.name}::control/${each.value.name}"
  target_identifier = [
    for x in data.aws_organizations_organizational_units.ou.children :
    x.arn if x.name == each.value.ou_name
  ][0]
}
*/
locals {
  control_name = flatten([
    for i in range(0, length(var.control_name)) : [
      for pair in setproduct(element(var.control_name, i).control_name, element(var.control_name, i).ou_name) :
      { "arn:aws:controltower:${data.aws_region.current.name}::control/${pair[0]}" = pair[1] }
    ]
  ])
}

resource "aws_controltower_control" "control" {
  for_each           = { for control in local.control_name : join(":", [keys(control)[0], values(control)[0]]) => [keys(control)[0], values(control)[0]] }
  control_identifier = each.value[0] #"arn:aws:controltower:${data.aws_region.current.name}::control/${each.value.name}"

  target_identifier = [
    for x in data.aws_organizations_organizational_units.ou.children :
    x.arn if x.name == each.value[1]
  ][0]
}