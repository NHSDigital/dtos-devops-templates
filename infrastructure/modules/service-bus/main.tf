resource "azurerm_servicebus_namespace" "this" {
  name                          = var.servicebus_namespace_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  sku                           = var.sku_tier
  capacity                      = var.capacity
  premium_messaging_partitions  = var.premium_messaging_partitions
  public_network_access_enabled = var.public_network_access_enabled

  tags = var.tags
}

resource "azurerm_servicebus_topic" "this" {
  for_each = var.servicebus_topic_map

  name                                    = coalesce(each.value.topic_name, each.key)
  namespace_id                            = azurerm_servicebus_namespace.this.id
  auto_delete_on_idle                     = each.value.auto_delete_on_idle
  batched_operations_enabled              = each.value.batched_operations_enabled
  default_message_ttl                     = each.value.default_message_ttl
  duplicate_detection_history_time_window = each.value.duplicate_detection_history_time_window
  partitioning_enabled                    = each.value.partitioning_enabled
  max_message_size_in_kilobytes           = each.value.max_message_size_in_kilobytes
  max_size_in_megabytes                   = each.value.max_size_in_megabytes
  requires_duplicate_detection            = each.value.requires_duplicate_detection
  support_ordering                        = each.value.support_ordering
  status                                  = each.value.status
}

resource "azurerm_servicebus_namespace_authorization_rule" "this" {
  name         = "access-rule"
  namespace_id = azurerm_servicebus_namespace.this.id

  listen = true
  send   = true
  manage = false
}


module "private_endpoint_service_bus_namespace" {
  count = var.private_endpoint_properties.private_endpoint_enabled ? 1 : 0

  source = "../private-endpoint"

  name                = "${var.servicebus_namespace_name}-servicebus-pep"
  resource_group_name = var.private_endpoint_properties.private_endpoint_resource_group_name
  location            = var.location
  subnet_id           = var.private_endpoint_properties.private_endpoint_subnet_id

  private_dns_zone_group = {
    name                 = "${var.servicebus_namespace_name}-pep-zone-group"
    private_dns_zone_ids = var.private_endpoint_properties.private_dns_zone_ids
  }

  private_service_connection = {
    name                           = "${var.servicebus_namespace_name}-pep-connection"
    private_connection_resource_id = azurerm_servicebus_namespace.this.id
    subresource_names              = ["namespace"]
    is_manual_connection           = var.private_endpoint_properties.private_service_connection_is_manual
  }

  tags = var.tags
}
