# Module documentation

## Required Inputs

The following input variables are required:

### <a name="input_name"></a> [name](#input\_name)

Description: value of the name of the diagnostic setting

Type: `string`

### <a name="input_target_resource_id"></a> [target\_resource\_id](#input\_target\_resource\_id)

Description: value of the target resource id

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_enabled_log"></a> [enabled\_log](#input\_enabled\_log)

Description: value of the enabled log

Type: `list(string)`

Default: `[]`

### <a name="input_eventhub_authorization_rule_id"></a> [eventhub\_authorization\_rule\_id](#input\_eventhub\_authorization\_rule\_id)

Description: value of the eventhub authorization rule id

Type: `string`

Default: `null`

### <a name="input_eventhub_name"></a> [eventhub\_name](#input\_eventhub\_name)

Description: value of the EventHub name if logging to an EventHub.

Type: `string`

Default: `null`

### <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id)

Description: Identifier of a log analytics workspace to send resource logging to via diagnostic settings if logging to log analytic workspace is being used.

Type: `string`

Default: `null`

### <a name="input_metric"></a> [metric](#input\_metric)

Description: value of the metric

Type: `list(string)`

Default: `[]`

### <a name="input_metric_enabled"></a> [metric\_enabled](#input\_metric\_enabled)

Description: True to retain diagnostic setting metrics, false otherwise

Type: `bool`

Default: `true`

### <a name="input_storage_account_id"></a> [storage\_account\_id](#input\_storage\_account\_id)

Description: value of the storage account id if logging to storage account is being used.

Type: `string`

Default: `null`


## Resources

The following resources are used by this module:

- [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) (resource)
