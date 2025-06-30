## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_monitor_metric_alert.planned_maintenance_alert](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_action_group_id"></a> [action\_group\_id](#input\_action\_group\_id) | ID of the action group to notify | `string` | n/a | yes |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Whether the alert rule is enabled | `bool` | `true` | no |
| <a name="input_evaluation_frequency"></a> [evaluation\_frequency](#input\_evaluation\_frequency) | How often to evaluate the alert rule (e.g., PT5M) | `string` | `"PT5M"` | no |
| <a name="input_frequency"></a> [frequency](#input\_frequency) | How often the metric alert is checked (e.g., PT1M) | `string` | `"PT5M"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the metric alert | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group where the alert will be created | `string` | n/a | yes |
| <a name="input_severity"></a> [severity](#input\_severity) | Severity level of the alert (0 is highest, 4 is lowest) | `number` | `2` | no |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | Subscription ID to monitor | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to associate with the alert | `map(string)` | `{}` | no |
| <a name="input_window_size"></a> [window\_size](#input\_window\_size) | Time window over which data is collected (e.g., PT5M) | `string` | `"PT15M"` | no |

## Outputs

No outputs.
