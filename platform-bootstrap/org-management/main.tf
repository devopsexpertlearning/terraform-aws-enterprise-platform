data "aws_organizations_organization" "main" {}

resource "aws_organizations_organizational_unit" "main" {
  name      = var.organization_unit_name
  parent_id = var.parent_id != "" ? var.parent_id : data.aws_organizations_organization.main.roots[0].id

  tags = local.common_tags
}
