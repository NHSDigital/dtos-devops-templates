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

resource "azurerm_monitor_metric_alert" "this" {
  name                = "${var.name}-metricalert"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_application_insights_standard_web_test.this,var.application_insights_id ]
  description         = "availability test alert"

  application_insights_web_test_location_availability_criteria {
    web_test_id           = azurerm_application_insights_web_test.this.id
    component_id          = var.application_insights_id
    failed_location_count = 1
  }

  action {
    action_group_id = var.action_group_id
  }
}
