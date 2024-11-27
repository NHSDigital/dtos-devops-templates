resource "azurerm_postgresql_flexible_server" "postgresql_flexible_server" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location


  public_network_access_enabled = var.public_network_access_enabled
  sku_name                      = var.sku_name
  storage_mb                    = var.storage_mb
  storage_tier                  = var.storage_tier
  version                       = var.server_version
  zone                          = var.zone

  backup_retention_days        = var.backup_retention_days
  geo_redundant_backup_enabled = var.geo_redundant_backup_enabled

  authentication {
    active_directory_auth_enabled = true
    password_auth_enabled         = false
    tenant_id                     = var.tenant_id
  }

  # Postgres Flexible Server does not support User Assigned Identity
  # so do not enable for now. If required, create the identity in an
  # associated identity module and reference it here.
  #
  # identity {
  #   type         = "SystemAssigned"
  # }

  tags = var.tags
}

# Create the Active Directory Administrator for the Postgres Flexible Server
resource "azurerm_postgresql_flexible_server_active_directory_administrator" "postgresql_admin" {
  server_name         = azurerm_postgresql_flexible_server.postgresql_flexible_server.name
  resource_group_name = var.resource_group_name
  tenant_id           = var.tenant_id
  object_id           = var.postgresql_admin_object_id
  principal_name      = var.postgresql_admin_principal_name
  principal_type      = var.postgresql_admin_principal_type
}

# Create the server configurations
resource "azurerm_postgresql_flexible_server_configuration" "postgresql_flexible_config" {
  for_each  = var.postgresql_configurations

  server_id = azurerm_postgresql_flexible_server.postgresql_flexible_server.id

  name      = each.key
  value     = each.value
}

/* --------------------------------------------------------------------------------------------------
  Private Endpoint Configuration for Postgres Flexible Server
-------------------------------------------------------------------------------------------------- */

module "private_endpoint_postgresql_flexible_server" {
  count = var.private_endpoint_properties.private_endpoint_enabled ? 1 : 0

  source = "../private-endpoint"

  name                = "${var.name}-postgresql-private-endpoint"
  resource_group_name = var.private_endpoint_properties.private_endpoint_resource_group_name
  location            = var.location
  subnet_id           = var.private_endpoint_properties.private_endpoint_subnet_id

  private_dns_zone_group = {
    name                 = "${var.name}-postgresql-private-endpoint-zone-group"
    private_dns_zone_ids = var.private_endpoint_properties.private_dns_zone_ids_postgresql
  }

  private_service_connection = {
    name                           = "${var.name}-postgresql-private-endpoint-connection"
    private_connection_resource_id = azurerm_postgresql_flexible_server.postgresql_flexible_server.id
    subresource_names              = ["postgresqlServer"]
    is_manual_connection           = var.private_endpoint_properties.private_service_connection_is_manual
  }

  tags = var.tags
}
