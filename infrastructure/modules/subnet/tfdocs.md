# Module documentation

## Required Inputs

The following input variables are required:

### <a name="input_address_prefixes"></a> [address\_prefixes](#input\_address\_prefixes)

Description: The address prefixes for the subnet.

Type: `list(string)`

### <a name="input_location"></a> [location](#input\_location)

Description: n/a

Type: `string`

### <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id)

Description: id of the log analytics workspace to send resource logging to via diagnostic settings

Type: `string`

### <a name="input_monitor_diagnostic_setting_network_security_group_enabled_logs"></a> [monitor\_diagnostic\_setting\_network\_security\_group\_enabled\_logs](#input\_monitor\_diagnostic\_setting\_network\_security\_group\_enabled\_logs)

Description: Controls what logs will be enabled for the NSG

Type: `list(string)`

### <a name="input_name"></a> [name](#input\_name)

Description: The name of the subnet.

Type: `string`

### <a name="input_network_security_group_name"></a> [network\_security\_group\_name](#input\_network\_security\_group\_name)

Description: The name of the network security group.

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The name of the resource group in which to create the VNET. Changing this forces a new resource to be created.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_create_nsg"></a> [create\_nsg](#input\_create\_nsg)

Description: Indicates whether a network security group should be created. (Some subnets such as those for VNEt Gateways cannot have NSGs)

Type: `bool`

Default: `true`

### <a name="input_default_outbound_access_enabled"></a> [default\_outbound\_access\_enabled](#input\_default\_outbound\_access\_enabled)

Description: Indicates whether the subnet has outbound access enabled.

Type: `bool`

Default: `true`

### <a name="input_delegation_name"></a> [delegation\_name](#input\_delegation\_name)

Description: The name of the delegation for the subnet.

Type: `string`

Default: `""`

### <a name="input_network_security_group_nsg_rules"></a> [network\_security\_group\_nsg\_rules](#input\_network\_security\_group\_nsg\_rules)

Description: The network security group rules.

Type:

```hcl
list(object({
    name                         = string
    priority                     = number
    direction                    = string
    access                       = string
    protocol                     = string
    source_port_range            = optional(string)
    source_port_ranges           = optional(list(string))
    destination_port_range       = optional(string)
    destination_port_ranges      = optional(list(string))
    source_address_prefix        = optional(string)
    source_address_prefixes      = optional(list(string))
    destination_address_prefix   = optional(string)
    destination_address_prefixes = optional(list(string))
  }))
```

Default: `[]`

### <a name="input_private_endpoint_network_policies"></a> [private\_endpoint\_network\_policies](#input\_private\_endpoint\_network\_policies)

Description: Enable or disable network policies for private endpoints.

Type: `string`

Default: `"Disabled"`

### <a name="input_service_delegation_actions"></a> [service\_delegation\_actions](#input\_service\_delegation\_actions)

Description: The actions for the service delegation.

Type: `list(string)`

Default: `[]`

### <a name="input_service_delegation_name"></a> [service\_delegation\_name](#input\_service\_delegation\_name)

Description: The name of the service delegation.

Type: `string`

Default: `""`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: Resource tags to be applied throughout the deployment.

Type: `map(string)`

Default: `{}`

### <a name="input_vnet_name"></a> [vnet\_name](#input\_vnet\_name)

Description: The name of the VNets to which the subnet will be associated.

Type: `string`

Default: `null`
## Modules

The following Modules are called:

### <a name="module_nsg"></a> [nsg](#module\_nsg)

Source: ../network-security-group

Version:
## Outputs

The following outputs are exported:

### <a name="output_address_prefixes"></a> [address\_prefixes](#output\_address\_prefixes)

Description: n/a

### <a name="output_id"></a> [id](#output\_id)

Description: n/a

### <a name="output_name"></a> [name](#output\_name)

Description: n/a
## Resources

The following resources are used by this module:

- [azurerm_subnet.subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) (resource)
- [azurerm_subnet_network_security_group_association.subnet_nsg_association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) (resource)
