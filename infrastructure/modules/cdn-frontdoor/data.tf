data "azurerm_dns_zone" "custom" {
  for_each = var.custom_domain

  provider = azurerm.dns

  name                = each.value.dns_zone_name
  resource_group_name = coalesce(each.value.zone_rg_name, var.public_dns_zone_rg_name)
}
