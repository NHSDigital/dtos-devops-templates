# Need to give the depolyment service principal the required permissions to the storage account
module "rbac_assignmnents" {
  for_each = { for idx, role in local.rbac_roles : idx => role }

  source = "../rbac-assignment"

  principal_id         = data.azurerm_client_config.current.object_id
  role_definition_name = each.value
  scope                = var.storage_account_id
}

data "azurerm_client_config" "current" {}

locals {
  rbac_roles = {
    storage_account_contributor    = "Storage Account Contributor"
    storage_blob_data_owner        = "Storage Blob Data Owner"
    storage_queue_data_contributor = "Storage Queue Data Contributor"
  }
}
