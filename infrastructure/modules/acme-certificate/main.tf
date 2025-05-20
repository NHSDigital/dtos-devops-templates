resource "random_password" "pfx" {
  length  = 30
  special = true
}

locals {
  common_name_no_wildcard             = replace(var.certificate.common_name, "*.", "")
  hostname_for_cname_with_dot         = var.certificate.dns_cname_zone_name != null ? replace(local.common_name_no_wildcard, var.certificate.dns_cname_zone_name, "") : null
  hostname_for_private_cname_with_dot = var.certificate.dns_private_cname_zone_name != null ? replace(local.common_name_no_wildcard, var.certificate.dns_private_cname_zone_name, "") : null
}

# Terraform Managed Identity will need DNS Contributor RBAC role on the DNS Zones being altered.
# Create CNAME record for any redirected DNS-01 challenges. Lego azuredns provider will validate this before allowing a redirected AZURE_ZONE_NAME.
resource "azurerm_dns_cname_record" "challenge_redirect" {
  count = var.certificate.dns_cname_zone_name != null ? 1 : 0

  provider = azurerm.dns_public

  name                = trim("_acme-challenge.${local.hostname_for_cname_with_dot}", ".")
  zone_name           = var.certificate.dns_cname_zone_name
  resource_group_name = coalesce(var.certificate.dns_challenge_zone_rg_name, var.public_dns_zone_resource_group_name)
  ttl                 = 60
  record              = "_acme-challenge.${local.hostname_for_cname_with_dot}${var.certificate.dns_challenge_zone_name}"

  tags = var.tags
}

# A Private DNS zone that overlaps the public namespace also needs the challenge CNAME record to pass Lego azuredns checks. Private DNS is regional.
resource "azurerm_private_dns_cname_record" "challenge_redirect_private" {
  for_each = (var.certificate.dns_private_cname_zone_name != null && var.certificate.dns_cname_zone_name != null) ? var.private_dns_zone_resource_groups : {}

  provider = azurerm.dns_private

  name                = trim("_acme-challenge.${local.hostname_for_private_cname_with_dot}", ".")
  zone_name           = var.certificate.dns_private_cname_zone_name
  resource_group_name = each.value.name
  ttl                 = 60
  record              = azurerm_dns_cname_record.challenge_redirect[0].record

  tags = var.tags
}

resource "acme_certificate" "this" {
  account_key_pem               = var.acme_registration_account_key_pem
  common_name                   = var.certificate.common_name
  subject_alternative_names     = var.certificate.subject_alternative_names
  key_type                      = var.certificate.key_type
  certificate_p12_password      = random_password.pfx.result
  revoke_certificate_on_destroy = var.certificate.revoke_certificate_on_destroy

  dns_challenge {
    provider = "azuredns"
    config = { # https://go-acme.github.io/lego/dns/azuredns/
      # AZURE_AUTH_METHOD     = "cli"
      AZURE_SUBSCRIPTION_ID = var.subscription_id_dns_public
      AZURE_RESOURCE_GROUP  = lookup(var.certificate, "zone_rg_name", var.public_dns_zone_resource_group_name)
      AZURE_ZONE_NAME       = var.certificate.dns_challenge_zone_name
    }
  }

  depends_on = [
    azurerm_dns_cname_record.challenge_redirect,
    azurerm_private_dns_cname_record.challenge_redirect_private
  ]
}

resource "azurerm_key_vault_certificate" "acme" {
  for_each = var.key_vaults

  name         = replace(replace(var.certificate.common_name, "*.", "wildcard-"), ".", "-")
  key_vault_id = each.value.key_vault_id

  certificate {
    contents = acme_certificate.this.certificate_p12
    password = random_password.pfx.result
  }

  tags = var.tags
}

# Workaround while App Service cannot import elliptic curve Key Vault Certificate objects
resource "azurerm_key_vault_secret" "acme" {
  for_each = var.key_vaults

  name         = "pfx-${replace(replace(var.certificate.common_name, "*.", "wildcard-"), ".", "-")}"
  key_vault_id = each.value.key_vault_id
  value        = acme_certificate.this.certificate_p12
  content_type = "application/x-pkcs12"

  tags = var.tags
}
