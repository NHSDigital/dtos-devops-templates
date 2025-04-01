resource "azuread_group_member" "linux_web_app" {
  for_each = toset(var.azuread_group_ids)

  group_object_id  = each.key
  member_object_id = azurerm_linux_web_app.linux_web_app.identity.0.principal_id
}
