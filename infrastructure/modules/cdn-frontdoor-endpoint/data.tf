data "azurerm_dns_zone" "custom" {
  for_each = var.custom_domains

  provider = azurerm.dns

  name                = each.value.dns_zone_name
  resource_group_name = each.value.dns_zone_rg_name
}

data "azurerm_cdn_frontdoor_firewall_policy" "waf" {
  for_each = { for k, v in var.security_policies : k => v if v.cdn_frontdoor_firewall_policy_name != null }

  name                = each.value.cdn_frontdoor_firewall_policy_name
  resource_group_name = each.value.cdn_frontdoor_firewall_policy_rg_name
}
