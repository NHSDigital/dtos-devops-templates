# Module documentation

## Required Inputs

The following input variables are required:

### <a name="input_name"></a> [name](#input\_name)

Description: The name of the NAT gateway.

Type: `string`

### <a name="input_public_ip_name"></a> [public\_ip\_name](#input\_public\_ip\_name)

Description: The name of the public IP address resource created for the NAT gateway.

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The name of the resource group in which to create the NAT gateway.

Type: `string`

### <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id)

Description: The ID of the subnet to associate with the NAT gateway.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_idle_timeout_in_minutes"></a> [idle\_timeout\_in\_minutes](#input\_idle\_timeout\_in\_minutes)

Description: The idle timeout in minutes for the NAT gateway. Must be between 4 and 120.

Type: `number`

Default: `4`

### <a name="input_location"></a> [location](#input\_location)

Description: The location/region where the NAT gateway will be created.

Type: `string`

Default: `"uksouth"`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: A mapping of tags to assign to the resource.

Type: `map(string)`

Default: `{}`

### <a name="input_zones"></a> [zones](#input\_zones)

Description: Availability zones for the NAT gateway and its public IP. Use ["1"] for a zonal deployment. An empty list deploys with no zone redundancy.

Type: `list(string)`

Default: `[]`
## Modules

The following Modules are called:

### <a name="module_pip"></a> [pip](#module\_pip)

Source: ../public-ip

Version:
## Outputs

The following outputs are exported:

### <a name="output_id"></a> [id](#output\_id)

Description: The ID of the NAT gateway.

### <a name="output_name"></a> [name](#output\_name)

Description: The name of the NAT gateway.

### <a name="output_public_ip_address"></a> [public\_ip\_address](#output\_public\_ip\_address)

Description: The public IP address associated with the NAT gateway.
## Resources

The following resources are used by this module:

- [azurerm_nat_gateway.nat_gateway](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nat_gateway) (resource)
- [azurerm_nat_gateway_public_ip_association.nat_gateway_pip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nat_gateway_public_ip_association) (resource)
- [azurerm_subnet_nat_gateway_association.nat_gateway_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_nat_gateway_association) (resource)
