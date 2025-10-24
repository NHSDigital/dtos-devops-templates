resource "azurerm_application_insights_standard_web_test" "this" {
  name = var.name

  location                = var.location
  resource_group_name     = var.resource_group_name
  application_insights_id = var.application_insights_id

  frequency = var.frequency
  timeout   = var.timeout
  enabled   = true

  request {
    url = var.target_url
  }

  geo_locations = var.geo_locations
}
