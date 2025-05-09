# Module documentation

## Required Inputs

The following input variables are required:

### <a name="input_policy_name"></a> [policy\_name](#input\_policy\_name)

Description: The name of the firewall policy

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The name of the resource group in which to create the firewall policy

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_dns_proxy_enabled"></a> [dns\_proxy\_enabled](#input\_dns\_proxy\_enabled)

Description: Is DNS proxy enabled for the firewall policy

Type: `bool`

Default: `false`

### <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers)

Description: The DNS servers for the firewall policy

Type: `list(string)`

Default: `[]`

### <a name="input_location"></a> [location](#input\_location)

Description: The location/region where the firewall policy should be created

Type: `string`

Default: `"uksouth"`

### <a name="input_sku"></a> [sku](#input\_sku)

Description: The SKU of the firewall policy

Type: `string`

Default: `"Standard"`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: A mapping of tags to assign to the resource.

Type: `map(string)`

Default: `{}`

### <a name="input_threat_intelligence_mode"></a> [threat\_intelligence\_mode](#input\_threat\_intelligence\_mode)

Description: The threat intelligence mode of the firewall policy

Type: `string`

Default: `"Alert"`

## Outputs

The following outputs are exported:

### <a name="output_id"></a> [id](#output\_id)

Description: value of the firewall policy id
## Resources

The following resources are used by this module:

- [azurerm_firewall_policy.firewall_policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/firewall_policy) (resource)
