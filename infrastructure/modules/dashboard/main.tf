resource "azurerm_portal_dashboard" "dashboard" {

  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  dashboard_properties = var.dashboard_properties
}
