# acme-certificate

A Terraform module to obtain publicly trusted SSL certificates from the Let's Encrypt Certificate Authority using the ACME protocol (Automatic Certificate Management Environment). This module provides an Azure-friendly certificate issuance workflow, addressing the lack of a native equivalent to AWS Certificate Manager.


## Features
- Uses the [vancluever/acme](https://registry.terraform.io/providers/vancluever/acme/latest/docs) provider for true stateful certificate management in Terraform, backed by [Lego](https://github.com/go-acme/lego) as the ACME implementation.
- Seamless certificate renewal within 30 days of expiry.
- Automates [DNS-01 challenges](https://letsencrypt.org/docs/challenge-types/) via the [Lego azuredns](https://go-acme.github.io/lego/dns/azuredns/) provider.
- Handles Lego's requirement for authoritative NS records on the leaf zone. e.g. if you need a certificate for `www.private.mydomain.com` but don't have a `private.mydomain.com` zone, you can use CNAME redirection.
- CNAME redirection of DNS challenge records, including optional creation of corresponding CNAMEs in Azure Private DNS zones to satisfy Lego's local checks (wildcards supported).
- Stores certificates in Azure Key Vault as Certificate objects.
- Also stores the certificate as a `.pfx` file in a base64-encoded Key Vault Secret with a strong randomised password, for compatibility with consumers that cannot use Certificate objects.
- Supports multiple subscriptions (e.g. hub/spoke models).
- Supports multiple Azure regions.

## Example Usage

**example.tfvars**
```hcl
acme_certificates = {
  screening_wildcard = {
    common_name             = "*.non-live.screening.nhs.uk"
    dns_challenge_zone_name = "non-live.screening.nhs.uk"
  }
  screening_www_private = {
    common_name             = "www.private.non-live.screening.nhs.uk"           # No Azure DNS zone for 'private', so we need a CNAME redirect
    dns_cname_zone_name     = "non-live.screening.nhs.uk"                       # CNAME: _acme-challenge.www.private -> _acme-challenge.www.acme.non-live.screening.nhs.uk
    dns_challenge_zone_name = "acme.non-live.screening.nhs.uk"                  # TXT: _acme-challenge.www.acme.non-live.screening.nhs.uk
  }
  nationalscreening_wildcard_private = {
    common_name                 = "*.private.non-live.nationalscreening.nhs.uk" # In this example we also have a private DNS zone of the same name
    dns_cname_zone_name         = "non-live.nationalscreening.nhs.uk"           # CNAME: _acme-challenge.private -> _acme-challenge.acme.non-live.nationalscreening.nhs.uk
    dns_private_cname_zone_name = "private.non-live.nationalscreening.nhs.uk"   # Same CNAME added into existing private zone, to satisfy Lego's checks
    dns_challenge_zone_name     = "acme.non-live.nationalscreening.nhs.uk"      # TXT: _acme-challenge.acme.non-live.nationalscreening.nhs.uk
  }
}
```

**certificate.tf**
```hcl
resource "acme_registration" "hub" {
  email_address = var.LETS_ENCRYPT_CONTACT_EMAIL
}

module "acme_certificate" {
  for_each = var.acme_certificates

  source = "../../dtos-devops-templates/infrastructure/modules/acme-certificate"

  providers = {
    azurerm             = azurerm
    azurerm.dns_public  = azurerm
    azurerm.dns_private = azurerm
  }

  acme_registration_account_key_pem   = acme_registration.hub.account_key_pem
  certificate_naming_key              = each.key
  certificate                         = each.value
  key_vaults                          = module.key_vault
  private_dns_zone_resource_groups    = azurerm_resource_group.private_dns_rg
  public_dns_zone_resource_group_name = var.dns_zone_rg_name_public
  subscription_id_dns_public          = var.TARGET_SUBSCRIPTION_ID
}
```

## Terraform documentation
For the list of inputs, outputs, resources... check the [terraform module documentation](tfdocs.md).
