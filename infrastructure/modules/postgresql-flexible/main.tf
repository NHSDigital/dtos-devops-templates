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
    password_auth_enabled         = var.password_auth_enabled
    tenant_id                     = var.tenant_id
  }

  administrator_login    = try(length(var.administrator_login), 0) > 0 && var.password_auth_enabled ? var.administrator_login : null
  administrator_password = try(length(var.administrator_login), 0) > 0 && var.password_auth_enabled ? random_password.admin_password[0].result : null

  # Postgres Flexible Server does not support User Assigned Identity
  # so do not enable for now. If required, create the identity in an
  # associated identity module and reference it here.
  #
  # identity {
  #   type         = "SystemAssigned"
  # }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      # Allow Azure to manage deployment zone. Ignore changes.
      zone,
      # Allow Azure to manage primary and standby server on fail-over. Ignore changes.
      high_availability[0].standby_availability_zone,
      # Required for import because of https://github.com/hashicorp/terraform-provider-azurerm/issues/15586
      create_mode
    ]
  }
}

resource "random_password" "admin_password" {
  count = try(length(var.administrator_login), 0) > 0 && var.password_auth_enabled ? 1 : 0

  length           = 30
  special          = true
  override_special = "!@#$%^&*()-_=+[]{}<>:?"
}

resource "azurerm_key_vault_secret" "db_admin_pwd" {
  count = try(length(var.administrator_login), 0) > 0 && var.password_auth_enabled ? 1 : 0

  name         = var.key_vault_admin_pwd_secret_name
  value        = resource.random_password.admin_password[0].result
  key_vault_id = var.key_vault_id
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

resource "azurerm_postgresql_flexible_server_active_directory_administrator" "admin_identity" {
  for_each = { for id in var.admin_identities : id.name => {
    principal_name = id.name
    object_id      = id.principal_id
  } }

  server_name         = azurerm_postgresql_flexible_server.postgresql_flexible_server.name
  resource_group_name = var.resource_group_name
  tenant_id           = var.tenant_id
  principal_name      = each.value.principal_name
  object_id           = each.value.object_id
  principal_type      = "ServicePrincipal"
}

# Create the server configurations
resource "azurerm_postgresql_flexible_server_configuration" "postgresql_flexible_config" {
  for_each = var.postgresql_configurations

  server_id = azurerm_postgresql_flexible_server.postgresql_flexible_server.id

  name  = each.key
  value = each.value
}

/* --------------------------------------------------------------------------------------------------
  Private Endpoint Configuration for Postgres Flexible Server
-------------------------------------------------------------------------------------------------- */

module "private_endpoint_postgresql_flexible_server" {
  count = can(var.private_endpoint_properties.private_endpoint_enabled) ? 1 : 0

  source = "../private-endpoint"

  name                = "${var.name}-postgresql-pep"
  resource_group_name = var.private_endpoint_properties.private_endpoint_resource_group_name
  location            = var.location
  subnet_id           = var.private_endpoint_properties.private_endpoint_subnet_id

  private_dns_zone_group = {
    name                 = "${var.name}-postgresql-pep-zone-group"
    private_dns_zone_ids = var.private_endpoint_properties.private_dns_zone_ids_postgresql
  }

  private_service_connection = {
    name                           = "${var.name}-postgresql-pep-connection"
    private_connection_resource_id = azurerm_postgresql_flexible_server.postgresql_flexible_server.id
    subresource_names              = ["postgresqlServer"]
    is_manual_connection           = var.private_endpoint_properties.private_service_connection_is_manual
  }

  tags = var.tags
}

/* --------------------------------------------------------------------------------------------------
  PostgreSQL Server Diagnostic Settings
-------------------------------------------------------------------------------------------------- */
module "diagnostic_setting_postgresql_server" {

  source = "../diagnostic-settings"

  name                       = "${var.name}-postgresql-server-diagnotic-setting"
  target_resource_id         = azurerm_postgresql_flexible_server.postgresql_flexible_server.id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  enabled_log                = var.monitor_diagnostic_setting_postgresql_server_enabled_logs
  metric                     = var.monitor_diagnostic_setting_postgresql_server_metrics
}
