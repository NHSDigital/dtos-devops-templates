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

  access_policy {

    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    certificate_permissions = ["Get", "List"]
    key_permissions         = ["Get", "List"]
    secret_permissions      = ["Get", "Set", "List"]
    storage_permissions     = ["Get", "List"]
  }

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

  source = "git::https://github.com/NHSDigital/dtos-devops-templates.git//infrastructure/modules/private-endpoint?ref=08100f7db2da6c0f64f327d15477a217a7ed4cd9"

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

