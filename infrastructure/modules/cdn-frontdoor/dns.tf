resource "azurerm_dns_a_record" "apex" {
  for_each = { for k, v in var.custom_domain : k => v if v.host_name == v.dns_zone_name }

  provider = azurerm.dns

  name                = "@"
  resource_group_name = coalesce(each.value.zone_rg_name, var.public_dns_zone_rg_name)
  target_resource_id  = azurerm_cdn_frontdoor_endpoint.this[each.value.cdn_frontdoor_endpoint_key].id
  ttl                 = 60
  zone_name           = each.value.dns_zone_name

  tags = var.tags
}

resource "azurerm_dns_cname_record" "custom" {
  for_each = { for k, v in var.custom_domain : k => v if v.host_name != v.dns_zone_name }

  provider = azurerm.dns

  name                = replace(each.value.host_name, ".${each.value.dns_zone_name}", "")
  zone_name           = each.value.dns_zone_name
  resource_group_name = coalesce(each.value.zone_rg_name, var.public_dns_zone_rg_name)
  ttl                 = 60
  target_resource_id  = azurerm_cdn_frontdoor_endpoint.this[each.value.cdn_frontdoor_endpoint_key].id

  tags = var.tags
}
