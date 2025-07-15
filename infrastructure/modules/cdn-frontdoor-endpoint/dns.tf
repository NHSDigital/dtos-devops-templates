# Terraform Managed Identity will need DNS Contributor RBAC role on the DNS Zones being altered.
resource "azurerm_dns_a_record" "root_alias" {
  for_each = { for k, v in var.custom_domains : k => v if v.host_name == v.dns_zone_name }

  provider = azurerm.dns

  name                = "@"
  resource_group_name = each.value.dns_zone_rg_name
  target_resource_id  = azurerm_cdn_frontdoor_endpoint.this.id
  ttl                 = 60
  zone_name           = each.value.dns_zone_name

  tags = var.tags
}

resource "azurerm_dns_cname_record" "custom" {
  for_each = { for k, v in var.custom_domains : k => v if v.host_name != v.dns_zone_name }

  provider = azurerm.dns

  name                = replace(each.value.host_name, ".${each.value.dns_zone_name}", "")
  zone_name           = each.value.dns_zone_name
  resource_group_name = each.value.dns_zone_rg_name
  ttl                 = 60
  target_resource_id  = azurerm_cdn_frontdoor_endpoint.this.id

  tags = var.tags
}

resource "azurerm_dns_txt_record" "challenge" {
  for_each = { for k, v in var.custom_domains : k => v if v.tls.certificate_type == "ManagedCertificate" }

  name                = join(".", compact(["_dnsauth", replace(each.value.host_name, ".${each.value.dns_zone_name}", "")]))
  zone_name           = each.value.dns_zone_name
  resource_group_name = each.value.dns_zone_rg_name
  ttl                 = 60

  record {
    value = azurerm_cdn_frontdoor_custom_domain.this[each.key].validation_token
  }
}
