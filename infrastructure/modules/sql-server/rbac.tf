module "rbac_assignments" {
  for_each = toset(local.rbac_roles)

  source = "../rbac-assignment"

  principal_id         = azurerm_mssql_server.azure_sql_server.identity[0].principal_id
  role_definition_name = each.key
  scope                = var.storage_account_id
}

locals {
  rbac_roles = [
    "Storage Account Contributor",
    "Storage Blob Data Owner",
    "Storage Queue Data Contributor"
  ]
}
