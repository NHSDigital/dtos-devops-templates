resource "azurerm_application_insights_standard_web_test" "this" {
  name = var.name

  location                = var.location
  resource_group_name     = var.resource_group_name
  application_insights_id = var.application_insights_id

  frequency = var.frequency
  timeout   = var.timeout
  enabled   = true

  request {
    url       = var.target_url
    http_verb = var.http_verb

    dynamic "header" {
      for_each = var.headers
      content {
        name  = header.key
        value = header.value
      }
    }
  }

  # SSL validation rules
  dynamic "validation_rules" {
    for_each = var.ssl_validation != null ? [1] : []
    content {
      expected_status_code        = var.ssl_validation.expected_status_code
      ssl_check_enabled           = true
      ssl_cert_remaining_lifetime = var.ssl_validation.ssl_cert_remaining_lifetime
    }
  }

  geo_locations = var.geo_locations
}
