data "azurerm_role_definition" "reader_role" {
  name  = "Reader"
  scope = var.role_scope_id
}

data "azurerm_role_definition" "contributor_role" {
  name  = "Contributor"
  scope = var.role_scope_id
}
