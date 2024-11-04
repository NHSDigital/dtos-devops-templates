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

  lifecycle {
    ignore_changes = [tags]
  }
}

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
