resource "azurerm_log_analytics_workspace" "log_analytics_workspace" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.law_sku
  retention_in_days   = var.retention_days

  # A Managed Identity is created by default when creating a Log Analytics Workspace but still
  # need to add the identity block to the resource to enable it to be accessible in the outputs
  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

/* --------------------------------------------------------------------------------------------------
  Diagnostic Settings
-------------------------------------------------------------------------------------------------- */

module "diagnostic-settings" {
  source = "../diagnostic-settings"

  name                       = "${var.name}-diagnostic-setting"
  target_resource_id         = azurerm_log_analytics_workspace.log_analytics_workspace.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_analytics_workspace.id
  enabled_log                = var.monitor_diagnostic_setting_log_analytics_workspace_enabled_logs
  enabled_metric             = var.monitor_diagnostic_setting_log_analytics_workspace_metrics

}
