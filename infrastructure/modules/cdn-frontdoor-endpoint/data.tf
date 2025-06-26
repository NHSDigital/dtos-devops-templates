data "azurerm_dns_zone" "custom" {
  for_each = { for v in values(var.custom_domains) : v.dns_zone_name => coalesce(v.zone_rg_name, var.public_dns_zone_rg_name)... }

  provider = azurerm.dns

  name                = each.key
  resource_group_name = each.value[0]
}

data "azurerm_cdn_frontdoor_firewall_policy" "waf" {
  for_each = var.security_policies

  name                = each.value.cdn_frontdoor_firewall_policy_name
  resource_group_name = coalesce(each.value.cdn_frontdoor_firewall_policy_rg_name, var.cdn_frontdoor_firewall_policy_rg_name)
}
