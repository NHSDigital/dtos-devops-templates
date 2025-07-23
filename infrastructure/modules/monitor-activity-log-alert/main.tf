resource "azurerm_monitor_activity_log_alert" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  scopes              = var.scopes
  description         = var.description
  enabled             = var.enabled

  dynamic "criteria" {
    for_each = var.criteria != null ? [var.criteria] : []
    content {
      category       = criteria.value.category
      level          = criteria.value.level
      dynamic "service_health" {
        for_each = try([criteria.value.service_health], [])
        content {
          events    = service_health.value.events
          locations = service_health.value.locations
          services  = service_health.value.services
        }
      }
    }
  }

  action {
    action_group_id    = var.action_group_id
    webhook_properties = var.webhook_properties
  }

  tags = var.tags
}
