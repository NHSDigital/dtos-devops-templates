resource "azurerm_mssql_server" "azure_sql_server" {

  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  version             = var.sqlversion

  minimum_tls_version           = var.tlsver
  public_network_access_enabled = var.public_network_access_enabled

  tags = var.tags

  azuread_administrator {
    azuread_authentication_only = var.ad_auth_only         # set to: true
    login_username              = var.sql_admin_group_name # azurerm_user_assigned_identity.uai-sql.name
    object_id                   = var.sql_admin_object_id  # azurerm_user_assigned_identity.uai-sql.principal_id
  }

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [tags]
  }
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
  SQL Server Diagnostic Settings
-------------------------------------------------------------------------------------------------- */
module "diagnostic_setting_sql_server" {

  source = "../diagnostic-settings"

  name                            = "${var.name}-sql-server-diagnotic-setting"
  target_resource_id              = "${azurerm_mssql_server.azure_sql_server.id}/databases/master"
  log_analytics_workspace_id      = var.log_analytics_workspace_id
  enabled_log                     = var.monitor_diagnostic_setting_sql_server_enabled_logs
  metric                          = var.monitor_diagnostic_setting_sql_server_metrics
  metric_enabled                  = var.metric_enabled
  metric_retention_policy_enabled = var.metric_retention_policy_enabled
  metric_retention_policy_days    = var.metric_retention_policy_days
}

/* --------------------------------------------------------------------------------------------------
  SQL Server Extended Auditing Policy
-------------------------------------------------------------------------------------------------- */
resource "azurerm_mssql_server_extended_auditing_policy" "azure_sql_server" {

  server_id              = azurerm_mssql_server.azure_sql_server.id
  log_monitoring_enabled = var.log_monitoring_enabled
  retention_in_days      = var.auditing_policy_retention_in_days
}

/* --------------------------------------------------------------------------------------------------
  Security Alert Policy for SQL Server
-------------------------------------------------------------------------------------------------- */
resource "azurerm_mssql_server_security_alert_policy" "sql_server_alert_policy" {

  server_name         = azurerm_mssql_server.azure_sql_server.name
  resource_group_name = var.resource_group_name
  state               = var.sql_server_alert_policy_state
  retention_days      = var.security_alert_policy_retention_days
}

/* --------------------------------------------------------------------------------------------------
  Vulnerability Assessment for SQL Server
-------------------------------------------------------------------------------------------------- */
resource "azurerm_mssql_server_vulnerability_assessment" "sql_server_vulnerability_assessment" {
  count = var.vulnerability_assessment_enabled ? 1 : 0

  server_security_alert_policy_id = azurerm_mssql_server_security_alert_policy.sql_server_alert_policy.id
  storage_container_path          = var.storage_container_id

  recurring_scans {
    enabled                   = true
    email_subscription_admins = true
  }
}
