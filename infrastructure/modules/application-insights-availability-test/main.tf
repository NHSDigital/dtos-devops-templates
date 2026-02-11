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
    body      = var.request_body

    dynamic "header" {
      for_each = var.headers
      content {
        name  = header.key
        value = header.value
      }
    }
  }

  # Validation rules
  dynamic "validation_rules" {
    for_each = var.ssl_validation.enabled ? [1] : []
    content {
      expected_status_code        = var.ssl_validation.expected_status_code
      ssl_check_enabled           = var.ssl_validation.ssl_check_enabled
      ssl_cert_remaining_lifetime = var.ssl_validation.ssl_cert_remaining_lifetime

      dynamic "content" {
        for_each = var.ssl_validation.content == null ? [] : [var.ssl_validation.content]
        content {
          content_match      = content.value.match
          ignore_case        = try(content.value.ignore_case, true)
          pass_if_text_found = try(content.value.pass_if_text_found, true)
        }
      }
    }
  }

  geo_locations = var.geo_locations
}
