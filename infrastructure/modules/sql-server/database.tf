
resource "azurerm_mssql_database" "defaultdb" {
  name                 = var.db_name_suffix # using only the suffix, as this is the naming convention from DToS Devs
  server_id            = azurerm_mssql_server.azure_sql_server.id
  collation            = var.collation
  license_type         = var.licence_type
  max_size_gb          = var.max_gb
  read_scale           = var.read_scale
  sku_name             = var.sku
  storage_account_type = var.storage_account_type
  zone_redundant       = var.zone_redundant


  tags = var.tags

  lifecycle {
    ignore_changes = [tags]
    # prevent the possibility of accidental data loss (variables may not be used here)
    prevent_destroy = false
  }
}

/* --------------------------------------------------------------------------------------------------
  SQL Database Diagnostic Settings
-------------------------------------------------------------------------------------------------- */
module "azurerm_monitor_diagnostic_setting_db" {

  source = "../diagnostic-settings"

  name                       = "${var.name}-database-diagnostic-settings"
  target_resource_id         = azurerm_mssql_database.defaultdb.id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  enabled_log                = var.monitor_diagnostic_setting_database_enabled_logs
  metric                     = var.monitor_diagnostic_setting_database_metrics
}

/* --------------------------------------------------------------------------------------------------
  SQL Database Configuration and Auditing Policy
-------------------------------------------------------------------------------------------------- */
resource "azurerm_mssql_database_extended_auditing_policy" "database_auditing_policy" {

  database_id       = azurerm_mssql_database.defaultdb.id
  storage_endpoint  = var.primary_blob_endpoint_name
  retention_in_days = var.auditing_policy_retention_in_days
}
