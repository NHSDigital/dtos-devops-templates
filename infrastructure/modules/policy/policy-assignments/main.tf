# Configure a policy assignment for a specific resource
resource "azurerm_resource_policy_assignment" "res_assignment" {
  count = var.assignment_type == "resource" && var.resource_id != "" ? 1 : 0

  name                 = var.assignment_name
  resource_id          = var.resource_id
  policy_definition_id = var.policy_definition_id
  enforce = var.enforce_policy
  location = var.policy_location

  identity {
    type = "SystemAssigned"
    identity_ids = var.policy_identities
  }
}

# Configure a policy assignment for a specific resource group
resource "azurerm_resource_group_policy_assignment" "rg_assignment" {
  count = var.assignment_type == "resource-group" && var.resource_group_id != "" ? 1 : 0

  name                 = var.assignment_name
  resource_group_id    = var.resource_group_id
  policy_definition_id = var.policy_definition_id
  enforce = var.enforce_policy
  location = var.policy_location

  identity {
    type = "SystemAssigned"
    identity_ids = var.policy_identities
  }
}

resource "azurerm_role_assignment" "role" {
  count = var.create_remediator_role ? 1 : 0

  scope                = var.policy_assignment_scope
  principal_id         = var.policy_assignment_principal_id
  role_definition_name = "Resource Policy Contributor"

  condition = <<EOT
  (
    (
      !(ActionMatches{'Microsoft.Authorization/policyAssignments/write')
      AND
      !(ActionMatches{'Microsoft.Authorization/policyDefinitions/write')
    )
    OR
    @Request[subOperation] ForAnyOfAnyValues:StringEqualsIgnoreCase {
      'remediate',
      'scan'
    }
  )
  EOT
  condition_version = "2.0"
}

# Configure diagnostic settings for the resource (group) policy assignment
module "policy_assignment_logs" {
  source = "../../diagnostic-settings"
  name                       = "policy-logs"
  target_resource_id         = local.assignment_id
  log_analytics_workspace_id = var.log_analytics_wks_id
}

locals {
  assignment_id = (
    var.assignment_type == "resource-group"
    ? azurerm_resource_group_policy_assignment.rg_assignment[0].id
    : azurerm_resource_policy_assignment.res_assignment[0].id
  )
}
