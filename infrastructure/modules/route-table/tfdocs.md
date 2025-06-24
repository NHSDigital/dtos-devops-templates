# Module documentation

## Required Inputs

The following input variables are required:

### <a name="input_bgp_route_propagation_enabled"></a> [bgp\_route\_propagation\_enabled](#input\_bgp\_route\_propagation\_enabled)

Description: Should BGP route propagation be enabled on this route table?

Type: `bool`

### <a name="input_location"></a> [location](#input\_location)

Description: The location/region where the route table is created.

Type: `string`

### <a name="input_name"></a> [name](#input\_name)

Description: The name of the route table.

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The name of the resource group in which to create the route table.

Type: `string`

### <a name="input_routes"></a> [routes](#input\_routes)

Description: A list of routes to add to the route table.

Type:

```hcl
list(object({
    name                   = string
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = optional(string)
  }))
```

### <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids)

Description: A list of subnet IDs to associate with the route table.

Type: `list(string)`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_tags"></a> [tags](#input\_tags)

Description: A map of tags to assign to the resource.

Type: `map(string)`

Default: `{}`

## Outputs

The following outputs are exported:

### <a name="output_id"></a> [id](#output\_id)

Description: n/a

### <a name="output_name"></a> [name](#output\_name)

Description: n/a
## Resources

The following resources are used by this module:

- [azurerm_route_table.route_table](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route_table) (resource)
- [azurerm_subnet_route_table_association.route_table_association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_route_table_association) (resource)
