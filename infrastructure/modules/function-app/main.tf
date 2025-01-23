resource "azurerm_linux_function_app" "function_app" {

  name                = var.function_app_name
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = var.asp_id

  app_settings = var.app_settings

  ftp_publish_basic_authentication_enabled       = var.ftp_publish_basic_authentication_enabled
  webdeploy_publish_basic_authentication_enabled = var.webdeploy_publish_basic_authentication_enabled

  https_only                    = var.https_only
  public_network_access_enabled = var.public_network_access_enabled
  virtual_network_subnet_id     = var.vnet_integration_subnet_id

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
    always_on                                     = var.always_on
    container_registry_use_managed_identity       = var.cont_registry_use_mi
    container_registry_managed_identity_client_id = var.acr_mi_client_id
    ftps_state                                    = var.ftps_state
    health_check_path                             = var.health_check_path
    health_check_eviction_time_in_min             = var.health_check_eviction_time_in_min
    minimum_tls_version                           = var.minimum_tls_version

    app_service_logs {
      disk_quota_mb         = var.app_service_logs_disk_quota_mb
      retention_period_days = var.app_service_logs_retention_period_days
    }

    application_stack {
      docker {
        registry_url = var.acr_login_server
        image_name   = var.image_name
        image_tag    = var.image_tag
      }
    }

    # Function app Firewall restrictions
    ip_restriction_default_action = var.ip_restriction_default_action

    dynamic "ip_restriction" {
      for_each = var.ip_restrictions
      content {
        headers                   = ip_restriction.value.headers
        ip_address                = ip_restriction.value.ip_address
        name                      = ip_restriction.value.name
        priority                  = ip_restriction.value.priority
        action                    = ip_restriction.value.action
        service_tag               = ip_restriction.value.service_tag
        virtual_network_subnet_id = ip_restriction.value.virtual_network_subnet_id
      }
    }


    use_32_bit_worker = var.worker_32bit
  }

  storage_account_name          = var.storage_account_name
  storage_account_access_key    = var.storage_account_access_key
  storage_uses_managed_identity = var.storage_uses_managed_identity

  tags = var.tags
}

/* --------------------------------------------------------------------------------------------------
  Private Endpoint Configuration
-------------------------------------------------------------------------------------------------- */

module "private_endpoint" {
  count = var.private_endpoint_properties.private_endpoint_enabled ? 1 : 0

  source = "../private-endpoint"

  name                = "${var.function_app_name}-private-endpoint"
  resource_group_name = var.private_endpoint_properties.private_endpoint_resource_group_name
  location            = var.location
  subnet_id           = var.private_endpoint_properties.private_endpoint_subnet_id

  private_dns_zone_group = {
    name                 = "${var.function_app_name}-private-endpoint-zone-group"
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

/* --------------------------------------------------------------------------------------------------
  Function App Slots
-------------------------------------------------------------------------------------------------- */

module "function_app_slots" {
  for_each = { for slot in var.function_app_slots : slot.function_app_slots_name => slot }

  source = "../function-app-slots"

  name                      = each.value.function_app_slots_name
  function_app_id           = azurerm_linux_function_app.function_app.id
  storage_account_name      = var.storage_account_name
  function_app_slot_enabled = each.value.function_app_slot_enabled

  tags = var.tags
}

/* --------------------------------------------------------------------------------------------------
  Diagnostic Settings
-------------------------------------------------------------------------------------------------- */

module "diagnostic-settings" {
  source = "../diagnostic-settings"

  name                       = "${var.function_app_name}-diagnostic-setting"
  target_resource_id         = azurerm_linux_function_app.function_app.id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  enabled_log                = var.monitor_diagnostic_setting_function_app_enabled_logs
  metric                     = var.monitor_diagnostic_setting_function_app_metrics

}
