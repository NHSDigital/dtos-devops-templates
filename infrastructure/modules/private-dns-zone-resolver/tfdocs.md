# Module documentation

## Required Inputs

The following input variables are required:

### <a name="input_location"></a> [location](#input\_location)

Description: The region where the resolver is created.

Type: `string`

### <a name="input_name"></a> [name](#input\_name)

Description: The name (in FQDN form) of the zone.

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The name of the resource group in which to create the zone. Changing this forces a new resource to be created.

Type: `string`

### <a name="input_vnet_id"></a> [vnet\_id](#input\_vnet\_id)

Description: The ID of the virtual network to which the zone will be linked.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_inbound_endpoint_config"></a> [inbound\_endpoint\_config](#input\_inbound\_endpoint\_config)

Description: The configuration for the inbound endpoint.

Type:

```hcl
object({
    name                         = string
    private_ip_allocation_method = string
    subnet_id                    = string
  })
```

Default:

```json
{
  "name": "",
  "private_ip_allocation_method": "",
  "subnet_id": ""
}
```

### <a name="input_outbound_endpoint_config"></a> [outbound\_endpoint\_config](#input\_outbound\_endpoint\_config)

Description: The configuration for the outbound endpoint.

Type:

```hcl
object({
    name      = string
    subnet_id = string
  })
```

Default:

```json
{
  "name": "",
  "subnet_id": ""
}
```

### <a name="input_tags"></a> [tags](#input\_tags)

Description: A mapping of tags to assign to the resource.

Type: `map(string)`

Default: `{}`

## Outputs

The following outputs are exported:

### <a name="output_name"></a> [name](#output\_name)

Description: n/a

### <a name="output_private_dns_resolver_ip"></a> [private\_dns\_resolver\_ip](#output\_private\_dns\_resolver\_ip)

Description: n/a
## Resources

The following resources are used by this module:

- [azurerm_private_dns_resolver.private_dns_resolver](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_resolver) (resource)
- [azurerm_private_dns_resolver_inbound_endpoint.private_dns_resolver_inbound_endpoint](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_resolver_inbound_endpoint) (resource)
- [azurerm_private_dns_resolver_outbound_endpoint.private_dns_resolver_outbound_endpoint](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_resolver_outbound_endpoint) (resource)
