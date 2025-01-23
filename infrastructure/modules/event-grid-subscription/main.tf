resource "azurerm_eventgrid_event_subscription" "eventgrid_event_subscription" {
  name  = var.subscription_name
  scope = var.azurerm_eventgrid_id

  dynamic "azure_function_endpoint" {
    for_each = var.subscriber_function_details
    content {
      function_id = azure_function_endpoint.value.function_endpoint
    }
  }

  storage_blob_dead_letter_destination {
    storage_account_id          = var.dead_letter_storage_account_id
    storage_blob_container_name = var.dead_letter_storage_account_container_name
  }

  # tags = var.tags
}


resource "azurerm_role_assignment" "eventgrid_subscription_role" {
  for_each = { for idx, endpoint in var.subscriber_function_details : idx => endpoint }

  principal_id         = each.value.principal_id
  role_definition_name = "EventGrid Data Receiver"
  scope                = var.azurerm_eventgrid_id
}
