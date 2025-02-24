resource "azurerm_eventgrid_event_subscription" "eventgrid_event_subscription" {
  name  = var.subscription_name
  scope = var.azurerm_eventgrid_id

  azure_function_endpoint {
    # This must be the resource ID of the Azure Function
    function_id = var.function_endpoint

    # Optional: configure batch options
    # max_events_batch_size           = 1   # e.g., deliver one event per batch
    # preferred_batch_size_in_kilobytes = 64
  }

  storage_blob_dead_letter_destination {
    storage_account_id          = var.dead_letter_storage_account_id
    storage_blob_container_name = var.dead_letter_storage_account_container_name
  }

  # tags = var.tags
}

resource "azurerm_role_assignment" "eventgrid_subscription_role" {
  principal_id         = var.principal_id
  role_definition_name = "EventGrid Data Receiver"
  scope                = var.azurerm_eventgrid_id
}
