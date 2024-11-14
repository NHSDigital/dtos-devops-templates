data "azurerm_dns_zone" "lookup" {
  name                = var.dns_zone_name
  resource_group_name = var.dns_zone_resource_group_name
}

locals {
  # There are multiple certs, and possibly multiple regional Key Vaults to store them in.
  # We cannot nest for loops inside a map, so first iterate all permutations as a list of objects...
  le_certs_object_list = flatten([
    for cert_key, cert_subject in var.certificates : [
      for region in keys(var.key_vaults) : {
        cert_key     = cert_key # 1st iterator
        region       = region   # 2nd iterator
        cert_subject = cert_subject
      }
    ]
  ])
  # ...then project them into a map with unique keys (combining the iterators), for consumption by a for_each meta argument
  letsencrypt_certs_map = {
    for item in local.le_certs_object_list : "${item.cert_key}-${item.region}" => item
  }
}

# references to the created certificates, for outputs
data "azurerm_key_vault_certificate" "letsencrypt" {
  for_each = local.letsencrypt_certs_map

  name         = replace(replace(each.value.cert_subject, "*.", "wildcard-"), ".", "-")
  key_vault_id = var.key_vaults[each.value.region].key_vault_id

  depends_on = [
    null_resource.letsencrypt_cert
  ]
}
