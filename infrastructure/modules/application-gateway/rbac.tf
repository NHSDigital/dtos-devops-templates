locals {
  rbac_roles_key_vault = [
    "Key Vault Certificate User",
    "Key Vault Crypto User",
    "Key Vault Secrets User"
  ]
}

module "key_vault_rbac_assignments" {
  for_each = toset(local.rbac_roles_key_vault)

  source = "../rbac-assignment"

  principal_id         = azurerm_user_assigned_identity.appgw.id
  role_definition_name = each.key
  scope                = var.key_vault_id
}
