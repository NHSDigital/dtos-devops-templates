resource "azurerm_api_management" "apim" {
  name                 = var.name
  location             = var.location
  resource_group_name  = var.resource_group_name
  publisher_name       = var.publisher_name
  publisher_email      = var.publisher_email
  public_ip_address_id = var.public_ip_address_id

  min_api_version = var.min_api_version

  sku_name = "${var.sku_name}_${var.sku_capacity}"
  zones    = var.zones

  virtual_network_type = var.virtual_network_type

  dynamic "virtual_network_configuration" {
    for_each = toset(var.virtual_network_configuration)
    content {
      subnet_id = virtual_network_configuration.value
    }
  }

  dynamic "additional_location" {
    for_each = var.additional_locations
    content {
      location             = additional_location.value.location
      capacity             = additional_location.value.capacity
      zones                = additional_location.value.zones
      public_ip_address_id = additional_location.value.public_ip_address_id
      dynamic "virtual_network_configuration" {
        for_each = additional_location.value.virtual_network_configuration
        content {
          subnet_id = virtual_network_configuration.value.subnet_id
        }
      }
    }
  }

  gateway_disabled = var.gateway_disabled

  dynamic "certificate" {
    for_each = var.certificate_details
    content {
      encoded_certificate  = certificates.value.encoded_certificate
      store_name           = certificates.value.store_name
      certificate_password = certificates.value.certificate_password
    }
  }

  dynamic "sign_in" {
    for_each = var.sign_in_enabled ? ["enabled"] : []
    content {
      enabled = var.sign_in_enabled
    }
  }

  dynamic "sign_up" {
    for_each = var.sign_up_enabled ? ["enabled"] : []

    content {
      enabled = var.sign_up_enabled
      dynamic "terms_of_service" {
        for_each = var.terms_of_service_configuration
        content {
          consent_required = terms_of_service.value.consent_required
          enabled          = terms_of_service.value.enabled
          text             = terms_of_service.value.text
        }
      }
    }
  }

  identity {
    type         = var.identity_type
    identity_ids = var.identity_ids != "SystemAssigned" ? var.identity_ids : []
  }

  tags = var.tags
}

# Moved hostname_configuration from main resource into this dedicated resource to overcome inconsistent ordering issues that resulted in changes on every plan
resource "azurerm_api_management_custom_domain" "apim" {
  count = length(concat(
    var.custom_domains_management,
    var.custom_domains_developer_portal,
    var.custom_domains_gateway,
    var.custom_domains_scm
  )) == 0 ? 0 : 1

  api_management_id = azurerm_api_management.apim.id

  dynamic "management" {
    for_each = var.custom_domains_management
    content {
      host_name                    = management.value.host_name
      key_vault_id                 = management.value.key_vault_id
      certificate                  = management.value.certificate
      certificate_password         = management.value.certificate_password
      negotiate_client_certificate = management.value.negotiate_client_certificate
    }
  }

  dynamic "developer_portal" {
    for_each = var.custom_domains_developer_portal
    content {
      host_name                    = developer_portal.value.host_name
      key_vault_id                 = developer_portal.value.key_vault_id
      certificate                  = developer_portal.value.certificate
      certificate_password         = developer_portal.value.certificate_password
      negotiate_client_certificate = developer_portal.value.negotiate_client_certificate
    }
  }

  dynamic "gateway" {
    for_each = var.custom_domains_gateway
    content {
      host_name                    = gateway.value.host_name
      default_ssl_binding          = gateway.value.default_ssl_binding
      key_vault_id                 = gateway.value.key_vault_id
      certificate                  = gateway.value.certificate
      certificate_password         = gateway.value.certificate_password
      negotiate_client_certificate = gateway.value.negotiate_client_certificate
    }
  }

  dynamic "scm" {
    for_each = var.custom_domains_scm
    content {
      host_name                    = scm.value.host_name
      key_vault_id                 = scm.value.key_vault_id
      certificate                  = scm.value.certificate
      certificate_password         = scm.value.certificate_password
      negotiate_client_certificate = scm.value.negotiate_client_certificate
    }
  }
}

resource "azurerm_api_management_identity_provider_aad" "apim" {
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = azurerm_api_management.apim.resource_group_name

  client_id       = var.client_id
  client_secret   = var.client_secret
  allowed_tenants = var.allowed_tenants
  client_library  = var.client_library
}

module "diagnostic-settings" {
  source = "../diagnostic-settings"

  name                       = "${var.name}-diagnostic-setting"
  target_resource_id         = azurerm_api_management.apim.id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  enabled_log                = var.monitor_diagnostic_setting_apim_enabled_logs
  metric                     = var.monitor_diagnostic_setting_apim_metrics
  metric_enabled             = var.metric_enabled
}
