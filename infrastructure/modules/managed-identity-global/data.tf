data "azurerm_resource_group" "target" {
  name = var.resource_group_name
}

data "azurerm_role_definition" "reader" {
  name  = "Reader"
  scope = data.azurerm_resource_group.target.id
}

data "azurerm_role_definition" "contributor" {
  name  = "Contributor"
  scope = data.azurerm_resource_group.target.id
}
