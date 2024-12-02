resource "azurerm_log_analytics_workspace" "log_analytics_workspace" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.law_sku
  retention_in_days   = var.retention_days

  # It is not necessary to create a managed identity for the Log Analytics Workspace as one is
  # created by default when the workspace is created with using the same name as the workspace.
  # identity {
  #   type = "SystemAssigned"
  # }

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
  metric                     = var.monitor_diagnostic_setting_log_analytics_workspace_metrics

}
