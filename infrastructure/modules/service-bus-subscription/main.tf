resource "azurerm_servicebus_subscription" "this" {
  name                 = var.subscription_name
  topic_id             = var.topic_id
  max_delivery_count   = var.max_delivery_count
  lock_duration        = "PT5M"  # ISO 8601 duration

}

resource "azurerm_role_assignment" "sb_role" {
  scope                = var.service_bus_namespace_id
  role_definition_name = "Azure Service Bus Data Receiver"  # or "Azure Service Bus Data Owner" if you want full control
  principal_id         = var.function_app_principal_id
}
