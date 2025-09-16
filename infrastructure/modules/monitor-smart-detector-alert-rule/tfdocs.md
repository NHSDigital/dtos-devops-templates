# Module documentation

## Required Inputs

The following input variables are required:

### <a name="input_action_group_id"></a> [action\_group\_id](#input\_action\_group\_id)

Description: Azure monitor action group ID.

Type: `string`

### <a name="input_description"></a> [description](#input\_description)

Description: description of the smart detector alert rule.

Type: `string`

### <a name="input_detector_type"></a> [detector\_type](#input\_detector\_type)

Description: Specifies the Built-In Smart Detector type that this alert rule will use.

Allowed values:
- FailureAnomaliesDetector
- RequestPerformanceDegradationDetector
- DependencyPerformanceDegradationDetector
- ExceptionVolumeChangedDetector
- TraceSeverityDetector
- MemoryLeakDetector

Type: `string`

### <a name="input_name"></a> [name](#input\_name)

Description: The name of the azurerm\_monitor\_smart\_detector\_alert\_rule.

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The name of the resource group to deploy Service Health alerts into.

Type: `string`

### <a name="input_scope_resource_ids"></a> [scope\_resource\_ids](#input\_scope\_resource\_ids)

Description: List of resource IDs the smart detector alert rule applies to.

Type: `list(string)`

### <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id)

Description: Azure subscription ID where the alert will be set.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_frequency"></a> [frequency](#input\_frequency)

Description: Specifies the frequency of this Smart Detector Alert Rule in ISO8601 duration format (e.g., PT5M, PT15M, PT1H).

Type: `string`

Default: `"PT1M"`

### <a name="input_severity"></a> [severity](#input\_severity)

Description: Specifies the severity level. Allowed values: Sev0, Sev1, Sev2, Sev3, Sev4.

Type: `string`

Default: `"Sev2"`


## Resources

The following resources are used by this module:

- [azurerm_monitor_smart_detector_alert_rule.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_smart_detector_alert_rule) (resource)
