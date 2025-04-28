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