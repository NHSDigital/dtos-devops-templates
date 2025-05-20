# Module documentation

## Required Inputs

The following input variables are required:

### <a name="input_acme_registration_account_key_pem"></a> [acme\_registration\_account\_key\_pem](#input\_acme\_registration\_account\_key\_pem)

Description: Account key for the ACME registration, created once in the root module.

Type: `string`

### <a name="input_certificate"></a> [certificate](#input\_certificate)

Description: Details of ACME certificate to be requested.

Type:

```hcl
object({
    common_name                   = string
    subject_alternative_names     = optional(list(string))
    dns_cname_zone_name           = optional(string) # CNAME for redirecting DNS-01 challenges
    dns_private_cname_zone_name   = optional(string) # CNAME for redirecting DNS-01 challenges
    dns_challenge_zone_name       = string
    dns_challenge_zone_rg_name    = optional(string)         # Allows override per certificate if needed
    key_type                      = optional(string, "P256") # Follow certbot default of ECDSA P256
    revoke_certificate_on_destroy = optional(bool, true)
  })
```

### <a name="input_certificate_naming_key"></a> [certificate\_naming\_key](#input\_certificate\_naming\_key)

Description: n/a

Type: `string`

### <a name="input_key_vaults"></a> [key\_vaults](#input\_key\_vaults)

Description: Key Vaults to store the certificates in, keyed by region.

Type: `map(any)`

### <a name="input_public_dns_zone_resource_group_name"></a> [public\_dns\_zone\_resource\_group\_name](#input\_public\_dns\_zone\_resource\_group\_name)

Description: n/a

Type: `string`

### <a name="input_subscription_id_dns_public"></a> [subscription\_id\_dns\_public](#input\_subscription\_id\_dns\_public)

Description: n/a

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_private_dns_zone_resource_groups"></a> [private\_dns\_zone\_resource\_groups](#input\_private\_dns\_zone\_resource\_groups)

Description: Private DNS Zone Resource Groups, keyed by region. Optionally used to satisfy Lego azuredns checks for CNAME redirections of DNS-01 challenges.

Type: `map(any)`

Default: `null`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: n/a

Type: `map(string)`

Default: `{}`

## Outputs

The following outputs are exported:

### <a name="output_key_vault_certificate"></a> [key\_vault\_certificate](#output\_key\_vault\_certificate)

Description: n/a
## Resources

The following resources are used by this module:

- [acme_certificate.this](https://registry.terraform.io/providers/vancluever/acme/latest/docs/resources/certificate) (resource)
- [azurerm_dns_cname_record.challenge_redirect](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_cname_record) (resource)
- [azurerm_key_vault_certificate.acme](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_certificate) (resource)
- [azurerm_key_vault_secret.acme](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) (resource)
- [azurerm_private_dns_cname_record.challenge_redirect_private](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_cname_record) (resource)
- [random_password.pfx](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) (resource)
