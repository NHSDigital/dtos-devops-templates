resource "azurerm_linux_function_app_slot" "function_app_slot" {
  count = var.function_app_slot_enabled ? 1 : 0

  name                 = var.name
  function_app_id      = var.function_app_id
  storage_account_name = var.storage_account_name

  site_config {}

  tags = var.tags

}
