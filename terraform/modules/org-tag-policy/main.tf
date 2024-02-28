# Read the tagging policy JSON file

data "local_file" "org_tagging_policy_file" {
  filename = "${path.module}/org-tag-policy.json"
}

# Define the AWS Organizations tag policy
resource "aws_organizations_policy" "org_tag_policy" {
  name        = var.org_tag_policy_name
  description = var.org_tag_policy_description
  type        = var.org_tag_policy_type
  content     = file("${path.module}/org-tag-policy.json")
}



# Attach the organization tagging policy to the root of the organization
resource "aws_organizations_policy_attachment" "org_tagging_policy_attachment" {
  policy_id = aws_organizations_policy.org_tag_policy.id
  target_id = var.org_policy_target_id
}


