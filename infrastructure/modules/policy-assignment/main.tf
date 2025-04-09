# Can it be fed in via tfvars instead of? data "azurerm_subscription" "current" {}

# Subscription Policy Assignment
resource "azurerm_subscription_policy_assignment" "this" {
  name                 = var.name
  policy_definition_id = azurerm_policy_definition.this.id
  subscription_id      = var.subscription_id
  enforce              = var.enforce

  non_compliance_messages = ["This resource is not compliant with the policy."]

  parameters = {
    log_analytics_workspace_id = var.log_analytics_workspace_id
  }
}

# Resource Group Policy Assignment
resource "azurerm_resource_group_policy_assignment" "this" {
  name                 = var.name
  resource_group_id    = azurerm_resource_group.this.id
  policy_definition_id = azurerm_policy_definition.this.id
  enforce              = var.enforce

  parameters = {
    log_analytics_workspace_id = var.log_analytics_workspace_id
  }
}



# count = var.vnet_integration_enabled ? 1 : 0

# count = can(var.private_endpoint_properties.private_endpoint_enabled) ? 1 : 0

# count = var.private_endpoint_properties.private_endpoint_enabled ? 1 : 0
