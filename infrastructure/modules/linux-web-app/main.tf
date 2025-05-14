resource "azurerm_linux_web_app" "this" {
  name                = var.linux_web_app_name
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = var.asp_id

  app_settings = var.app_settings

  ftp_publish_basic_authentication_enabled       = var.ftp_publish_basic_authentication_enabled
  webdeploy_publish_basic_authentication_enabled = var.webdeploy_publish_basic_authentication_enabled

  https_only                    = var.https_only
  public_network_access_enabled = var.public_network_access_enabled
  virtual_network_subnet_id     = var.vnet_integration_subnet_id

  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = var.assigned_identity_ids
  }

  site_config {
    always_on                                     = var.always_on
    container_registry_use_managed_identity       = var.cont_registry_use_mi
    container_registry_managed_identity_client_id = var.acr_mi_client_id
    ftps_state                                    = var.ftps_state
    minimum_tls_version                           = var.minimum_tls_version
    health_check_path                             = var.health_check_path
    health_check_eviction_time_in_min = var.health_check_path == null ? null : (
      var.health_check_eviction_time_in_min == null ? 10 : var.health_check_eviction_time_in_min
    )

    application_stack {
      docker_registry_url = "https://${var.acr_login_server}"
      docker_image_name   = var.docker_image_name
    }

    # Linux web app Firewall restrictions
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

  dynamic "storage_account" {
    for_each = var.storage_name != null ? [1] : []

    content {
      access_key   = var.storage_account_access_key
      account_name = var.storage_account_name
      name         = var.storage_name
      share_name   = var.share_name
      type         = var.storage_type
    }
  }

  tags = var.tags
}


/* --------------------------------------------------------------------------------------------------
  Custom Domain and Certificate Bindings
-------------------------------------------------------------------------------------------------- */

resource "azurerm_dns_txt_record" "validation" {
  for_each = toset(var.custom_domains)

  provider = azurerm.dns # Terraform Managed Identity will need DNS Contributor RBAC role on the DNS Zone

  name                = "asuid.${split(".", each.key)[0]}"
  zone_name           = replace(each.key, "${split(".", each.key)[0]}.", "")
  resource_group_name = var.public_dns_zone_rg_name
  ttl                 = 300

  record {
    value = azurerm_linux_web_app.this.custom_domain_verification_id
  }
}

resource "azurerm_app_service_custom_hostname_binding" "this" {
  for_each = toset(var.custom_domains)

  hostname            = each.key
  app_service_name    = azurerm_linux_web_app.this.name
  resource_group_name = azurerm_linux_web_app.this.resource_group_name

  depends_on = [azurerm_dns_txt_record.validation]

  # Ignore ssl_state and thumbprint as they are managed using azurerm_app_service_certificate_binding
  lifecycle {
    ignore_changes = [ssl_state, thumbprint]
  }
}

resource "azurerm_app_service_certificate_binding" "this" {
  for_each = toset(var.custom_domains)

  hostname_binding_id = azurerm_app_service_custom_hostname_binding.this[each.key].id
  certificate_id      = var.wildcard_ssl_cert_id
  ssl_state           = "SniEnabled"
}


/* --------------------------------------------------------------------------------------------------
  Private Endpoint Configuration
-------------------------------------------------------------------------------------------------- */

module "private_endpoint" {
  count = var.private_endpoint_properties.private_endpoint_enabled ? 1 : 0

  source = "../private-endpoint"

  name                = "${var.linux_web_app_name}-private-endpoint"
  resource_group_name = var.private_endpoint_properties.private_endpoint_resource_group_name
  location            = var.location
  subnet_id           = var.private_endpoint_properties.private_endpoint_subnet_id

  private_dns_zone_group = {
    name                 = "${var.linux_web_app_name}-private-endpoint-zone-group"
    private_dns_zone_ids = var.private_endpoint_properties.private_dns_zone_ids
  }

  private_service_connection = {
    name                           = "${var.linux_web_app_name}-private-endpoint-connection"
    private_connection_resource_id = azurerm_linux_web_app.this.id
    subresource_names              = ["sites"]
    is_manual_connection           = var.private_endpoint_properties.private_service_connection_is_manual
  }

  tags = var.tags
}

/* --------------------------------------------------------------------------------------------------
  Linux Web App Slots
-------------------------------------------------------------------------------------------------- */

module "linux_web_app_slots" {
  for_each = { for slot in var.linux_web_app_slots : slot.linux_web_app_slots_name => slot }

  source = "../linux-web-app-slots"

  name                        = each.value.linux_web_app_slots_name
  linux_web_app_id            = azurerm_linux_web_app.this.id
  linux_web_app_slots_enabled = each.value.linux_web_app_slots_enabled

  storage_account_access_key = var.storage_account_access_key
  storage_account_name       = var.storage_account_name
  storage_name               = var.storage_name
  share_name                 = var.share_name
  storage_type               = var.storage_type


  tags = var.tags
}

/* --------------------------------------------------------------------------------------------------
  Diagnostic Settings
-------------------------------------------------------------------------------------------------- */

module "diagnostic-settings" {
  source = "../diagnostic-settings"

  name                       = "${var.linux_web_app_name}-diagnostic-setting"
  target_resource_id         = azurerm_linux_web_app.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  enabled_log                = var.monitor_diagnostic_setting_linux_web_app_enabled_logs
  metric                     = var.monitor_diagnostic_setting_linux_web_app_metrics

}
