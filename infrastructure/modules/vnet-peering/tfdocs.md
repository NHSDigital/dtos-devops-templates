# Module documentation

## Required Inputs

The following input variables are required:

### <a name="input_allow_forwarded_traffic"></a> [allow\_forwarded\_traffic](#input\_allow\_forwarded\_traffic)

Description: Controls if forwarded traffic from the VMs in the linked virtual network space is allowed.

Type: `bool`

### <a name="input_allow_gateway_transit"></a> [allow\_gateway\_transit](#input\_allow\_gateway\_transit)

Description: Controls gatewayLinks associated with the remote virtual network.

Type: `bool`

### <a name="input_allow_virtual_network_access"></a> [allow\_virtual\_network\_access](#input\_allow\_virtual\_network\_access)

Description: Controls if the VMs in the linked virtual network space would be able to access all the VMs in the local virtual network space.

Type: `bool`

### <a name="input_name"></a> [name](#input\_name)

Description: The name of the Peering connection.

Type: `string`

### <a name="input_remote_vnet_id"></a> [remote\_vnet\_id](#input\_remote\_vnet\_id)

Description: The ID of the remote virtual network to peer with.

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The name of the resource group in which to create the peering.

Type: `string`

### <a name="input_use_remote_gateways"></a> [use\_remote\_gateways](#input\_use\_remote\_gateways)

Description: Controls if remote gateways can be used on the linked virtual network.

Type: `bool`

### <a name="input_vnet_name"></a> [vnet\_name](#input\_vnet\_name)

Description: The name of the local virtual network to peer with.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_peer_complete_virtual_networks_enabled"></a> [peer\_complete\_virtual\_networks\_enabled](#input\_peer\_complete\_virtual\_networks\_enabled)

Description: Specifies whether complete Virtual Network address space is peered. Defaults to true. (Optional)

Type: `bool`

Default: `true`

### <a name="input_remote_subnet_names"></a> [remote\_subnet\_names](#input\_remote\_subnet\_names)

Description: A list of remote Subnet names from remote Virtual Network that are Subnet peered. (Optional)

Type: `list(string)`

Default: `[]`

## Outputs

The following outputs are exported:

### <a name="output_id"></a> [id](#output\_id)

Description: n/a

### <a name="output_name"></a> [name](#output\_name)

Description: n/a
## Resources

The following resources are used by this module:

- [azurerm_virtual_network_peering.peering](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering) (resource)
