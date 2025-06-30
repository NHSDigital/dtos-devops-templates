# Module documentation

## Required Inputs

The following input variables are required:

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The name of the resource group to deploy Service Health alerts into.

Type: `string`

### <a name="input_service_health_email_id"></a> [service\_health\_email\_id](#input\_service\_health\_email\_id)

Description: Azure monitor action group service health email ID.

Type: `string`

### <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id)

Description: Azure subscription ID where the alert will be set.

Type: `string`


## Resources

The following resources are used by this module:

- [azurerm_monitor_smart_detector_alert_rule.service_health_incident_alert](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_smart_detector_alert_rule) (resource)
