# Need to give the depolyment service principal the required permissions to the storage account
module "rbac_assignmnents" {
  for_each = { for idx, role in local.rbac_roles : idx => role }

  source = "../rbac-assignment"

  # There is an issue when trying to read the principal_id after it has been created so we
  # have to use a data lookup instead of getting the value directly from the SQL module
  # See bug report: https://github.com/hashicorp/terraform-provider-azurerm/issues/20767
  # principal_id         = azurerm_mssql_server.azure_sql_server.identity[0].principal_id

  principal_id         = data.azurerm_mssql_server.azure_sql_server.identity[0].principal_id
  role_definition_name = each.value
  scope                = var.storage_account_id
}

data "azurerm_client_config" "current" {}

data "azurerm_mssql_server" "azure_sql_server" {
  name                = azurerm_mssql_server.azure_sql_server.name
  resource_group_name = azurerm_mssql_server.azure_sql_server.resource_group_name
}

locals {
  rbac_roles = {
    storage_account_contributor    = "Storage Account Contributor"
    storage_blob_data_owner        = "Storage Blob Data Owner"
    storage_queue_data_contributor = "Storage Queue Data Contributor"
  }
}
