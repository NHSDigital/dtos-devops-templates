data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "keyvault" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  enabled_for_disk_encryption   = var.disk_encryption
  public_network_access_enabled = var.public_network_access_enabled
  purge_protection_enabled      = var.purge_protection_enabled
  soft_delete_retention_days    = var.soft_delete_retention
  sku_name                      = var.sku_name

  enable_rbac_authorization = var.enable_rbac_authorization

  tags = var.tags

  lifecycle {
    ignore_changes = [tags, contact]
  }
}

/* --------------------------------------------------------------------------------------------------
  Private Endpoint Configuration for Azure Keyvault
-------------------------------------------------------------------------------------------------- */

module "private_endpoint_keyvault" {
  count = var.private_endpoint_properties.private_endpoint_enabled ? 1 : 0

  source = "../private-endpoint"

  name                = "${var.name}-azure-keyvault-private-endpoint"
  resource_group_name = var.private_endpoint_properties.private_endpoint_resource_group_name
  location            = var.location
  subnet_id           = var.private_endpoint_properties.private_endpoint_subnet_id

  private_dns_zone_group = {
    name                 = "${var.name}-azure-keyvault-private-endpoint-zone-group"
    private_dns_zone_ids = var.private_endpoint_properties.private_dns_zone_ids_keyvault
  }

  private_service_connection = {
    name                           = "${var.name}-keyvault-private-endpoint-connection"
    private_connection_resource_id = azurerm_key_vault.keyvault.id
    subresource_names              = ["vault"]
    is_manual_connection           = var.private_endpoint_properties.private_service_connection_is_manual
  }

  tags = var.tags
}

/* --------------------------------------------------------------------------------------------------
  Diagnostic Settings
-------------------------------------------------------------------------------------------------- */

module "diagnostic-settings" { #needs to be changed to an underscore.
  source = "../diagnostic-settings"

  name                            = "${var.name}-diagnostic-setting"
  target_resource_id              = azurerm_key_vault.keyvault.id
  log_analytics_workspace_id      = var.log_analytics_workspace_id
  enabled_log                     = var.monitor_diagnostic_setting_keyvault_enabled_logs
  metric                          = var.monitor_diagnostic_setting_keyvault_metrics
  # metric_enabled                  = var.metric_enabled
  # metric_retention_policy_enabled = var.metric_retention_policy_enabled
  # metric_retention_policy_days    = var.metric_retention_policy_days

}

