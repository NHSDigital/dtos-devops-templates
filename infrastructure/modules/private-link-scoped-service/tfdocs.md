# Module documentation

## Required Inputs

The following input variables are required:

### <a name="input_linked_resource_id"></a> [linked\_resource\_id](#input\_linked\_resource\_id)

Description: The ID of the resource to link to the private link service.

Type: `string`

### <a name="input_name"></a> [name](#input\_name)

Description: The name of the Azure Monitor Private Link Scoped Service.

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The name of the resource group in which to create the zone. Changing this forces a new resource to be created.

Type: `string`

### <a name="input_scope_name"></a> [scope\_name](#input\_scope\_name)

Description: The name of the private link scope.

Type: `string`

## Outputs

The following outputs are exported:

### <a name="output_private_link_scoped_service_id"></a> [private\_link\_scoped\_service\_id](#output\_private\_link\_scoped\_service\_id)

Description: n/a
## Resources

The following resources are used by this module:

- [azurerm_monitor_private_link_scoped_service.ampls_service](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_private_link_scoped_service) (resource)
