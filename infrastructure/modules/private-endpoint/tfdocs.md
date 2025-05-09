# Module documentation

## Required Inputs

The following input variables are required:

### <a name="input_location"></a> [location](#input\_location)

Description: The location/region where the private endpoint will be created.

Type: `string`

### <a name="input_name"></a> [name](#input\_name)

Description: The name of the private endpoint.

Type: `string`

### <a name="input_private_dns_zone_group"></a> [private\_dns\_zone\_group](#input\_private\_dns\_zone\_group)

Description: Private DNS zone configuration

Type:

```hcl
object({
    name                 = string
    private_dns_zone_ids = list(string)
  })
```

### <a name="input_private_service_connection"></a> [private\_service\_connection](#input\_private\_service\_connection)

Description: Private service connection configuration.

Type:

```hcl
object({
    name                           = string
    private_connection_resource_id = string
    subresource_names              = list(string)
    is_manual_connection           = bool
  })
```

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The name of the resource group in which to create the private endpoint.

Type: `string`

### <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id)

Description: The ID of the subnet within which the private endpoint will be created.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_tags"></a> [tags](#input\_tags)

Description: A mapping of tags to assign to the resource.

Type: `map(string)`

Default: `{}`

## Outputs

The following outputs are exported:

### <a name="output_azurerm_private_endpoint"></a> [azurerm\_private\_endpoint](#output\_azurerm\_private\_endpoint)

Description: n/a

### <a name="output_id"></a> [id](#output\_id)

Description: n/a

### <a name="output_name"></a> [name](#output\_name)

Description: n/a
## Resources

The following resources are used by this module:

- [azurerm_private_endpoint.private_endpoint](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) (resource)
