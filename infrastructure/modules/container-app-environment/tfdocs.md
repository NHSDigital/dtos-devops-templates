# Module documentation

## Required Inputs

The following input variables are required:

### <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id)

Description: ID of the log analytics workspace to send resource logging to via diagnostic settings

Type: `string`

### <a name="input_name"></a> [name](#input\_name)

Description: Name of the container app environment.

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: Name of the resource group to create the container app environment in.

Type: `string`

### <a name="input_vnet_integration_subnet_id"></a> [vnet\_integration\_subnet\_id](#input\_vnet\_integration\_subnet\_id)

Description: ID of the subnet for the container app environment. Must be at least /23

Type: `string`

## Outputs

The following outputs are exported:

### <a name="output_default_domain"></a> [default\_domain](#output\_default\_domain)

Description: n/a

### <a name="output_id"></a> [id](#output\_id)

Description: n/a
## Resources

The following resources are used by this module:

- [azurerm_container_app_environment.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app_environment) (resource)
- [azurerm_resource_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) (data source)
