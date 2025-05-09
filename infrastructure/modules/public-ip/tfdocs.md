# Module documentation

## Required Inputs

The following input variables are required:

### <a name="input_name"></a> [name](#input\_name)

Description: The name of the public IP address.

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The name of the resource group in which to create the public IP address.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_allocation_method"></a> [allocation\_method](#input\_allocation\_method)

Description: The allocation method for the public IP address.

Type: `string`

Default: `"Static"`

### <a name="input_ddos_protection_mode"></a> [ddos\_protection\_mode](#input\_ddos\_protection\_mode)

Description: The DDoS protection plan mode.

Type: `string`

Default: `"VirtualNetworkInherited"`

### <a name="input_domain_name_label"></a> [domain\_name\_label](#input\_domain\_name\_label)

Description: The domain name label for the public IP address.

Type: `string`

Default: `null`

### <a name="input_location"></a> [location](#input\_location)

Description: The location/region where the public IP address will be created.

Type: `string`

Default: `"uksouth"`

### <a name="input_sku"></a> [sku](#input\_sku)

Description: The SKU of the public IP address.

Type: `string`

Default: `"Standard"`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: A mapping of tags to assign to the resource.

Type: `map(string)`

Default: `{}`

### <a name="input_zones"></a> [zones](#input\_zones)

Description: A list of availability zones which the public IP address should be allocated in.

Type: `list(string)`

Default: `[]`

## Outputs

The following outputs are exported:

### <a name="output_id"></a> [id](#output\_id)

Description: n/a

### <a name="output_ip_address"></a> [ip\_address](#output\_ip\_address)

Description: n/a

### <a name="output_name"></a> [name](#output\_name)

Description: n/a

### <a name="output_zones"></a> [zones](#output\_zones)

Description: n/a
## Resources

The following resources are used by this module:

- [azurerm_public_ip.pip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) (resource)
