resource "azurerm_resource_policy_remediation" "remediation" {
  name                    = var.remediation_name
  policy_assignment_id    = var.policy_assignment_id
  resource_discovery_mode = "ExistingNonCompliant"
  resource_id             = var.resource_id
}
