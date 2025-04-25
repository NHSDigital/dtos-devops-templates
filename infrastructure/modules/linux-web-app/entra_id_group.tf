resource "azuread_group_member" "function_app" {
  for_each = toset(var.entra_id_group_ids)

  group_object_id  = each.key
  member_object_id = azurerm_linux_web_app.this.identity.0.principal_id
}
