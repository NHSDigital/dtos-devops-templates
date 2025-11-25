# Module documentation

## Required Inputs

The following input variables are required:

### <a name="input_location"></a> [location](#input\_location)

Description: The location/region where the dashboard is created.

Type: `string`

### <a name="input_name"></a> [name](#input\_name)

Description: Is the dashboard workspace name.

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The name of the resource group in which the Dashboard is created. Changing this forces a new resource to be created.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_dashboard_properties"></a> [dashboard\_properties](#input\_dashboard\_properties)

Description: JSON data representing dashboard body. See above for details on how to obtain this from the Portal.

Type: `string`

Default: `"{}"`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: A mapping of tags to assign to the resource.

Type: `map(string)`

Default: `{}`


## Resources

The following resources are used by this module:

- [azurerm_portal_dashboard.dashboard](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/portal_dashboard) (resource)
