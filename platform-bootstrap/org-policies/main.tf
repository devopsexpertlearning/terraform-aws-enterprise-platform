resource "aws_organizations_policy" "deny_leaving_org" {
  count       = var.org_policy_deny_leaving_org_enabled ? 1 : 0
  name        = "${var.environment}-deny-leaving-org"
  description = "Deny accounts from leaving the Organization"
  type        = "SERVICE_CONTROL_POLICY"
  content     = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Action": [
        "organizations:LeaveOrganization"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
  tags        = var.tags
}

resource "aws_organizations_policy" "protect_security_services" {
  count       = var.org_policy_protect_security_services_enabled ? 1 : 0
  name        = "${var.environment}-protect-security-services"
  description = "Prevent disabling GuardDuty, Macie, SecurityHub, and CloudTrail"
  type        = "SERVICE_CONTROL_POLICY"
  content     = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Action": [
        "cloudtrail:StopLogging",
        "cloudtrail:DeleteTrail",
        "config:DeleteConfigurationRecorder",
        "config:DeleteDeliveryChannel",
        "config:StopConfigurationRecorder",
        "guardduty:DeleteDetector",
        "guardduty:DisableOrganizationAdminAccount",
        "securityhub:DisableSecurityHub",
        "macie2:DisableMacie"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
  tags        = var.tags
}
