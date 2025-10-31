# Module documentation

## Required Inputs

The following input variables are required:

### <a name="input_appinsights_type"></a> [appinsights\_type](#input\_appinsights\_type)

Description: Type of Application Insigts (default: web).

Type: `string`

### <a name="input_location"></a> [location](#input\_location)

Description: The location/region where the AI is created.

Type: `string`

### <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id)

Description: Is the LAW workspace ID in Audit subscription.

Type: `string`

### <a name="input_name"></a> [name](#input\_name)

Description: Is the App Insights workspace name.

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The name of the resource group in which the App Insights is created. Changing this forces a new resource to be created.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_action_group_id"></a> [action\_group\_id](#input\_action\_group\_id)

Description: The ID of the Action Group to use for alerts.

Type: `string`

Default: `null`

### <a name="input_alert_frequency"></a> [alert\_frequency](#input\_alert\_frequency)

Description: The frequency an alert is checked e.g. PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H.

Type: `string`

Default: `"PT5M"`

### <a name="input_enable_alerting"></a> [enable\_alerting](#input\_enable\_alerting)

Description: Whether monitoring and alerting is enabled for this module.

Type: `bool`

Default: `false`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: A mapping of tags to assign to the resource.

Type: `map(string)`

Default: `{}`

## Outputs

The following outputs are exported:

### <a name="output_connection_string"></a> [connection\_string](#output\_connection\_string)

Description: n/a

### <a name="output_id"></a> [id](#output\_id)

Description: n/a

### <a name="output_name"></a> [name](#output\_name)

Description: n/a

### <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name)

Description: n/a
## Resources

The following resources are used by this module:

- [azurerm_application_insights.appins](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights) (resource)
- [azurerm_monitor_metric_alert.exceptions](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) (resource)
