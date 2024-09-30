resource "azurerm_linux_function_app" "function_app" {

  name                = var.function_app_name
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = var.asp_id

  app_settings = var.app_settings

  ftp_publish_basic_authentication_enabled = var.ftp_publish_basic_authentication_enabled
  https_only                               = var.https_only
  public_network_access_enabled            = var.private_endpoint_properties.public_network_access_enabled
  virtual_network_subnet_id                = var.private_endpoint_properties.vnet_integration_subnet_id

  # Commented out as does not seem compatible with the current version of the azurerm provider
  # cors {
  #   allowed_origins     = var.cors_allowed_origins # List of allowed origins
  #   support_credentials = false
  # }

  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = var.assigned_identity_ids
  }

  site_config {
    application_insights_connection_string        = var.ai_connstring
    container_registry_use_managed_identity       = var.cont_registry_use_mi
    container_registry_managed_identity_client_id = var.acr_mi_client_id
    ftps_state                                    = var.ftps_state
    minimum_tls_version                           = var.minimum_tls_version

    application_stack {
      docker {
        registry_url = var.acr_login_server
        image_name   = var.image_name
        image_tag    = var.image_tag
      }
    }

    use_32_bit_worker = var.worker_32bit
  }

  storage_account_name       = var.sa_name
  storage_account_access_key = var.sa_prm_key

  tags = var.tags
}

/* --------------------------------------------------------------------------------------------------
  Private Endpoint Configuration
-------------------------------------------------------------------------------------------------- */

module "private_endpoint" {
  count = var.private_endpoint_properties.private_endpoint_enabled ? 1 : 0

  source = "git::https://github.com/NHSDigital/dtos-devops-templates.git//infrastructure/modules/private-endpoint?ref=feat/DTOSS-3386-Private-Endpoint-Updates"

  name                = "${var.function_app_name}-private-endpoint"
  resource_group_name = var.private_endpoint_properties.private_endpoint_resource_group_name
  location            = var.location
  subnet_id           = var.private_endpoint_properties.private_endpoint_subnet_id

  private_dns_zone_group = {
    name                 = "privatelink.azurewebsites.net"
    private_dns_zone_ids = var.private_endpoint_properties.private_dns_zone_ids
  }

  private_service_connection = {
    name                           = "${var.function_app_name}-private-endpoint-connection"
    private_connection_resource_id = azurerm_linux_function_app.function_app.id
    subresource_names              = ["sites"]
    is_manual_connection           = var.private_endpoint_properties.private_service_connection_is_manual
  }

  tags = var.tags
}
