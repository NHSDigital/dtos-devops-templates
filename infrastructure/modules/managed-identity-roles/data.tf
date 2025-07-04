data "azurerm_resource_group" "target_resource_group" {
  name = var.resource_group_name
}

data "azurerm_role_definition" "reader_role" {
  name  = "Reader"
  scope = data.azurerm_resource_group.target_resource_group.id
}

data "azurerm_role_definition" "contributor_role" {
  name  = "Contributor"
  scope = data.azurerm_resource_group.target_resource_group.id
}
