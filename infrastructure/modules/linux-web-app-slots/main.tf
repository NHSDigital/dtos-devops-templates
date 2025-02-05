resource "azurerm_linux_web_app_slot" "linux_web_app_slots" {
  count = var.linux_web_app_slots_enabled ? 1 : 0

  name           = var.name
  app_service_id = var.linux_web_app_id
  storage_account {
    access_key   = var.storage_account_access_key
    account_name = var.storage_account_name
    name         = var.storage_name
    share_name   = var.share_name
    type         = var.storage_type
  }

  site_config {}

  tags = var.tags

}
