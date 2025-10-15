resource "azurerm_application_insights_standard_web_test" "this" {
  count = var.use_standard ? 1 : 0

  name                    = var.name
  location                = var.location
  resource_group_name     = var.resource_group_name
  application_insights_id = var.application_insights_id

  enabled   = var.enabled
  kind      = var.kind # e.g. "standard"
  frequency = var.frequency
  timeout   = var.timeout

  # Standard tests use a JSON configuration block instead of XML in many cases.
  configuration = var.standard_configuration

  # optional fields
  geo_locations = var.geo_locations
  tags          = var.tags
}
