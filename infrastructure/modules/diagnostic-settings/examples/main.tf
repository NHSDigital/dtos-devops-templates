module "diagnostic-settings" {
  for_each = var.storage_account_service

  source                     = "./module/diagnostic-settings"
  name                       = "example-diagnotic-setting-storage"
  target_resource_id         = "${azurerm_storage_account.example.id}/${each.value}/default"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
  enabled_log                = ["StorageWrite", "StorageRead", "StorageDelete"]
  enabled_metric             = ["AllMetrics"]

}
