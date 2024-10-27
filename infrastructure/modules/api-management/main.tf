resource "azurerm_api_management" "apim" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  publisher_name      = var.publisher_name
  publisher_email     = var.publisher_email
  public_ip_address_id = var.public_ip_address_id

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

  identity {
    type         = var.identity_type
    identity_ids = var.identity_ids != "SystemAssigned" ? var.identity_ids : []
  }

  tags = var.tags
}
