resource "azurerm_log_analytics_data_export_rule" "export_rule" {

  name                    = var.name
  resource_group_name     = var.resource_group_name
  workspace_resource_id   = var.workspace_resource_id
  destination_resource_id = var.destination_resource_id
  table_names             = var.table_names
  enabled                 = var.enabled
}
