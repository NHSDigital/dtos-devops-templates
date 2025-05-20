# acme-certificate

A Terraform module to obtain publicly trusted SSL certificates from the Let's Encrypt Certificate Authority using the ACME protocol (Automatic Certificate Management Environment). This module provides an Azure-friendly certificate issuance workflow, addressing the lack of a native equivalent to AWS Certificate Manager.


## Features
- Uses the [vancluever/acme](https://registry.terraform.io/providers/vancluever/acme/latest/docs) provider for true stateful certificate management in Terraform, backed by [Lego](https://github.com/go-acme/lego) as the ACME implementation.
- Seamless certificate renewal within 30 days of expiry.
- Automates [DNS-01 challenges](https://letsencrypt.org/docs/challenge-types/) via the [Lego azuredns](https://go-acme.github.io/lego/dns/azuredns/) provider.
- Handles Lego's requirement for authoritative NS records on the leaf zone. e.g. if you need a certificate for `www.private.example.com` but only have a zone for `example.com`, you can use CNAME redirection (see examples below).
- CNAME redirection of DNS challenge records, including optional creation of corresponding CNAMEs in Azure Private DNS zones to satisfy Lego's local checks (wildcards supported).
- Stores certificates in Azure Key Vault as Certificate objects.
- Also stores the certificate as a `.pfx` file in a base64-encoded Key Vault Secret with a strong randomised password, for compatibility with consumers that cannot use Certificate objects.
- Supports multiple subscriptions (e.g. hub/spoke models).
- Supports multiple Azure regions.

## Example Usage

**example.tfvars**
```hcl
acme_certificates = {                                  # RESULT
  simple = {
    common_name             = "*.example.com"          # Wildcards are stripped
    dns_challenge_zone_name = "example.com"            # TXT _acme-challenge.example.com
  }
  redirected = {
    common_name             = "www.foo.example.com"    # No Azure DNS zone for 'foo', use a CNAME to redirect DNS-01 challenge
    dns_cname_zone_name     = "example.com"            # CNAME _acme-challenge.www.foo resolving to the below record
    dns_challenge_zone_name = "acme.example.com"       # TXT _acme-challenge.www.foo.acme.example.com
  }
  redirected_split_horizon = {
    common_name                 = "*.bar.example.com"  # In this example we also have a private DNS zone bar.example.com
    dns_cname_zone_name         = "example.com"        # CNAME _acme-challenge.bar resolving to the below record
    dns_challenge_zone_name     = "acme.example.com"   # TXT _acme-challenge.bar.acme.example.com
    dns_private_cname_zone_name = "bar.example.com"    # CNAME _acme-challenge resolving to the above record (satisfying Lego checks)
  }
}
```
> ⚠️ `dns_cname_zone_name` and `dns_private_cname_zone_name` must match part of `common_name`, while `dns_challenge_zone_name` can be any public zone you control.

**certificate.tf**
```hcl
resource "acme_registration" "hub" {
  email_address = var.acme_contact_email
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
  subscription_id_dns_public          = var.subscription_id_target
}
```

To reference a resulting Key Vault Certificate:
```hcl
module.acme_certificate["simple"].key_vault_certificate["uksouth"].versionless_secret_id
```

To reference a resulting `.pfx` certificate file:
```hcl
module.acme_certificate["simple"].key_vault_certificate["uksouth"].pfx_blob_secret_name
module.acme.certificate["simple"].key_vault_certificate["uksouth"].pfx_password
```

## Testing

Remember to use the ACME staging API in your terraform providers block until the code works to your satisfaction.

Remove your test certificates from your Terraform state before switching accounts or before switching between API endpoints. By default the provider will try to revoke certificates with ACME on destroy, and if you accidentally delete or replace the account first this will result in a continual:

> _Error: acme: error: 400 :: POST :: https://acme-staging-v02.api.letsencrypt.org/acme/new-acct :: urn:ietf:params:acme:error:accountDoesNotExist :: No account exists with the provided key_

which can only be resolved by manually pruning the certificates from the state file:
```bash
terraform state rm "module.acme_certificate[\"example\"].acme_certificate.this"
```

## Terraform documentation
For the list of inputs, outputs, resources... check the [terraform module documentation](tfdocs.md).
