# Module documentation

## Required Inputs

The following input variables are required:

### <a name="input_certificates"></a> [certificates](#input\_certificates)

Description: Map of certificates names with their subject names (DNS names).

Type: `map(string)`

### <a name="input_dns_zone_names"></a> [dns\_zone\_names](#input\_dns\_zone\_names)

Description: Map of zone identifiers to their full private DNS zone names

Type: `map(string)`

### <a name="input_dns_zone_resource_group_name"></a> [dns\_zone\_resource\_group\_name](#input\_dns\_zone\_resource\_group\_name)

Description: n/a

Type: `string`

### <a name="input_email"></a> [email](#input\_email)

Description: Contact email address for certificate expiry notifications.

Type: `string`

### <a name="input_environment"></a> [environment](#input\_environment)

Description: n/a

Type: `string`

### <a name="input_key_vaults"></a> [key\_vaults](#input\_key\_vaults)

Description: Key Vaults to store the certificates in.

Type: `map(any)`

### <a name="input_storage_account_name_hub"></a> [storage\_account\_name\_hub](#input\_storage\_account\_name\_hub)

Description: n/a

Type: `string`

### <a name="input_subscription_id_hub"></a> [subscription\_id\_hub](#input\_subscription\_id\_hub)

Description: n/a

Type: `string`

### <a name="input_subscription_id_target"></a> [subscription\_id\_target](#input\_subscription\_id\_target)

Description: n/a

Type: `string`

## Outputs

The following outputs are exported:

### <a name="output_key_vault_certificates"></a> [key\_vault\_certificates](#output\_key\_vault\_certificates)

Description: key is "${cert\_key}-${region}"
## Resources

The following resources are used by this module:

- [local_file.certbot_ini_file](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) (resource)
- [null_resource.letsencrypt_cert](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) (resource)
- [azurerm_dns_zone.lookup](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/dns_zone) (data source)
- [azurerm_key_vault_certificate.letsencrypt](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_certificate) (data source)
