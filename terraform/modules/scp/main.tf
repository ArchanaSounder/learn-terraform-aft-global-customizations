locals {
  json_file_ext = trimsuffix(var.json_file, ".json")
  path_removed  = trimprefix(local.json_file_ext, "policies/")
  scp_name      = replace(local.path_removed, "/s.*//", "")
}



resource "aws_organizations_policy" "scp" {
  name    = local.scp_name
  content = file(var.json_file)
}

resource "aws_organizations_policy_attachment" "scp-attachment" {
  for_each  = toset(var.ou_list)
  policy_id = aws_organizations_policy.scp.id
  target_id = each.value
}