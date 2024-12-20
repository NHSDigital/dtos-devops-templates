resource "azurerm_eventgrid_topic" "azurerm_eventgrid" {
  name                = var.topic_name
  resource_group_name = var.resource_group_name
  location            = var.location

  identity {
    type = var.identity_type
  }

  dynamic "inbound_ip_rule" {
    for_each = var.inbound_ip_rules
    content {
      ip_mask = inbound_ip_rule.value["ip_mask"]
      action  = inbound_ip_rule.value["action"]
    }
  }

  tags = var.tags
}
