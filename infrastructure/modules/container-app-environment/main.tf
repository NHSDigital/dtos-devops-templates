resource "azurerm_container_app_environment" "main" {
  name                           = var.name
  location                       = data.azurerm_resource_group.main.location
  resource_group_name            = var.resource_group_name
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  infrastructure_subnet_id       = var.vnet_integration_subnet_id
  internal_load_balancer_enabled = true
}
