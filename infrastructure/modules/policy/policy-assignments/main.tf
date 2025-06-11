# Configure a policy assignment for a specific resource
resource "azurerm_resource_policy_assignment" "res_assignment" {
  count = var.resource_id != "" && local.resource_id_type == "resource" ? 1 : 0

  name                 = var.assignment_name
  resource_id          = var.resource_id
  policy_definition_id = var.policy_definition_id
  enforce              = var.enforce_policy
  location             = var.policy_location

  dynamic "identity" {
    for_each = var.requires_identity ? [1] : []
    content {
      type         = "SystemAssigned"
      identity_ids = var.policy_identities
    }
  }
}

# Configure a policy assignment for a specific resource group
resource "azurerm_resource_group_policy_assignment" "rg_assignment" {
  count = var.resource_id != "" && local.resource_id_type == "resource-group" ? 1 : 0

  name                 = var.assignment_name
  resource_group_id    = var.resource_id
  policy_definition_id = var.policy_definition_id
  enforce              = var.enforce_policy
  location             = var.policy_location

  dynamic "identity" {
    for_each = var.requires_identity ? [1] : []
    content {
      type         = "SystemAssigned"
      identity_ids = var.policy_identities
    }
  }
}

# Configure a policy assignment for a specific resource group
resource "azurerm_subscription_policy_assignment" "sub_assignment" {
  count = var.resource_id != "" && local.resource_id_type == "subscription" ? 1 : 0

  name                 = var.assignment_name
  subscription_id      = var.resource_id
  policy_definition_id = var.policy_definition_id
  enforce              = var.enforce_policy
  location             = var.policy_location

  dynamic "identity" {
    for_each = var.requires_identity ? [1] : []
    content {
      type         = "SystemAssigned"
      identity_ids = var.policy_identities
    }
  }
}

resource "azurerm_role_assignment" "role" {
  count = var.create_remediator_role ? 1 : 0

  scope                = var.policy_assignment_scope
  principal_id         = var.policy_assignment_principal_id
  role_definition_name = "Resource Policy Contributor"

  condition         = <<EOT
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
  source                     = "../../diagnostic-settings"
  name                       = "policy-logs"
  target_resource_id         = local.assignment_id
  log_analytics_workspace_id = var.log_analytics_wks_id
  enabled_log                = var.enabled_log
}

locals {

  resource_id_type = (
    can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+$", var.resource_id)) ? "resource-group" :
    can(regex("^/subscriptions/[^/]+$", var.resource_id)) ? "subscription" :
    can(regex("^/providers/Microsoft.Management/managementGroups/[^/]+$", var.resource_id)) ? "management-group" :
    "resource"
  )

  assignment_map = {
    "resource-group"   = try(azurerm_resource_group_policy_assignment.rg_assignment[0], null)
    "resource"         = try(azurerm_resource_policy_assignment.res_assignment[0], null)
    "subscription"     = try(azurerm_subscription_policy_assignment.sub_assignment[0], null)
    "management-group" = null
  }

  active_assignment = lookup(local.assignment_map, local.resource_id_type, null)

  assignment_id = try(local.active_assignment.id, null)
  principal_id  = try(local.active_assignment.identity[0].principal_id, null)
}
