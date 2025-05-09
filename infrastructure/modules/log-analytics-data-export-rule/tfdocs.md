# Module documentation

## Required Inputs

The following input variables are required:

### <a name="input_destination_resource_id"></a> [destination\_resource\_id](#input\_destination\_resource\_id)

Description: The resource ID of the destination where the data will be exported.

Type: `string`

### <a name="input_enabled"></a> [enabled](#input\_enabled)

Description: Whether the data export rule is enabled.

Type: `bool`

### <a name="input_name"></a> [name](#input\_name)

Description: The name of the Log Analytics Data Export Rule.

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The name of the resource group in which to create the Log Analytics Data Export Rule.

Type: `string`

### <a name="input_table_names"></a> [table\_names](#input\_table\_names)

Description: A list of table names to export data from.

Type: `list(string)`

### <a name="input_workspace_resource_id"></a> [workspace\_resource\_id](#input\_workspace\_resource\_id)

Description: The resource ID of the Log Analytics workspace.

Type: `string`


## Resources

The following resources are used by this module:

- [azurerm_log_analytics_data_export_rule.export_rule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_data_export_rule) (resource)
