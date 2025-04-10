
# Subscription Policy Assignment
resource "azurerm_subscription_policy_assignment" "this" {
  count = var.subscription_id != null

  name                 = var.name
  policy_definition_id = var.policy_definition_id
  subscription_id      = var.subscription_id
  enforce              = var.enforce

  non_compliance_messages = ["This resource is not compliant with policy ${var.policy_definition_id}."]

  parameters = jsonencode({
    log_analytics_workspace_id = {
      value = var.log_analytics_workspace_id
    }
  })
}

# Resource Group Policy Assignment
resource "azurerm_resource_group_policy_assignment" "this" {
  count = var.resource_group_id != null

  name                 = var.name
  policy_definition_id = var.policy_definition_id
  resource_group_id    = var.resource_group_id
  enforce              = var.enforce



  parameters = jsonencode({
    log_analytics_workspace_id = {
      value = var.log_analytics_workspace_id
    }
  })
}
