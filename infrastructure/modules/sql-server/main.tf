resource "azurerm_mssql_server" "azure_sql_server" {

  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  version             = var.sqlversion
  # retention_in_days   = var.retention_in_days

  minimum_tls_version           = var.tlsver
  public_network_access_enabled = var.public_network_access_enabled

  tags = var.tags

  azuread_administrator {
    azuread_authentication_only = var.ad_auth_only         # set to: true
    login_username              = var.sql_admin_group_name # azurerm_user_assigned_identity.uai-sql.name
    object_id                   = var.sql_admin_object_id  # azurerm_user_assigned_identity.uai-sql.principal_id
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

/* --------------------------------------------------------------------------------------------------
  SQL Server Extended Auditing Policy
-------------------------------------------------------------------------------------------------- */
resource "azurerm_mssql_server_extended_auditing_policy" "azure_sql_server" {
  server_id              = azurerm_mssql_server.azure_sql_server.id
  log_monitoring_enabled = true
}

/* --------------------------------------------------------------------------------------------------
  SQL Server Diagnostic Settings
-------------------------------------------------------------------------------------------------- */
module "azurerm_monitor_diagnostic_setting_sql_server" {
  source                     = "../diagnostic-settings"
  name                       = "${var.name}-sql-server-diagnotic-setting"
  target_resource_id         = "${azurerm_mssql_server.azure_sql_server.id}/databases/master"
  log_analytics_workspace_id = var.log_analytics_workspace_id
  enabled_log                = ["SQLSecurityAuditEvents"]
  metric                     = ["AllMetrics"]
}

/* --------------------------------------------------------------------------------------------------
  SQL Server Firewall
-------------------------------------------------------------------------------------------------- */
resource "azurerm_mssql_firewall_rule" "firewall_rule" {
  for_each = var.firewall_rules

  name             = each.value.fw_rule_name
  server_id        = azurerm_mssql_server.azure_sql_server.id
  start_ip_address = each.value.start_ip
  end_ip_address   = each.value.end_ip
}

/* --------------------------------------------------------------------------------------------------
  Private Endpoint Configuration for SQL Server
-------------------------------------------------------------------------------------------------- */

module "private_endpoint_sql_server" {
  count = var.private_endpoint_properties.private_endpoint_enabled ? 1 : 0

  source = "../private-endpoint"

  name                = "${var.name}-sql-private-endpoint"
  resource_group_name = var.private_endpoint_properties.private_endpoint_resource_group_name
  location            = var.location
  subnet_id           = var.private_endpoint_properties.private_endpoint_subnet_id

  private_dns_zone_group = {
    name                 = "${var.name}-sql-private-endpoint-zone-group"
    private_dns_zone_ids = var.private_endpoint_properties.private_dns_zone_ids_sql
  }

  private_service_connection = {
    name                           = "${var.name}-sql-private-endpoint-connection"
    private_connection_resource_id = azurerm_mssql_server.azure_sql_server.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = var.private_endpoint_properties.private_service_connection_is_manual
  }

  tags = var.tags
}

/* --------------------------------------------------------------------------------------------------
  Security Alert Policy for SQL Server
-------------------------------------------------------------------------------------------------- */

resource "azurerm_mssql_server_security_alert_policy" "sql_server_alert_policy" {
  server_name         = azurerm_mssql_server.azure_sql_server.name
  resource_group_name = var.resource_group_name
  state               = "Enabled"
}

/* --------------------------------------------------------------------------------------------------
  Vulnerability Assessment for SQL Server
-------------------------------------------------------------------------------------------------- */

resource "azurerm_mssql_server_vulnerability_assessment" "sql_server_vulnerability_assessment" {
  server_security_alert_policy_id = azurerm_mssql_server_security_alert_policy.sql_server_alert_policy.id
  storage_container_path          = "${azurerm_storage_account.storage_account_name.primary_blob_endpoint}${azurerm_storage_container.vulnerability_assessment_container.name}/"
  # storage_account_access_key      = azurerm_storage_account.storage_account_name.primary_access_key

  recurring_scans {
    enabled                   = true
    email_subscription_admins = true
    # emails                    = ["?", "?"]
  }
}

/* --------------------------------------------------------------------------------------------------
  SQL Database Configuration and Auditing Policy
-------------------------------------------------------------------------------------------------- */
resource "azurerm_mssql_database_extended_auditing_policy" "database_auditing_policy" {
  database_id      = azurerm_mssql_database.defaultdb.id
  storage_endpoint = azurerm_storage_account.storage_account_name.primary_blob_endpoint
  # storage_account_access_key              = azurerm_storage_account.storage_account_name.primary_access_key
  # storage_account_access_key_is_secondary = false
  retention_in_days = var.retention_in_days
}

/* --------------------------------------------------------------------------------------------------
  SQL Database Diagnostic Settings
-------------------------------------------------------------------------------------------------- */
module "azurerm_monitor_diagnostic_setting_db" {
  source                     = "../diagnostic-settings"
  name                       = "${var.name}-database-diagnostic-settings"
  target_resource_id         = azurerm_mssql_server.defaultdb.id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  enabled_log                = ["SQLSecurityAuditEvents"]
  metric                     = ["AllMetrics"]
}