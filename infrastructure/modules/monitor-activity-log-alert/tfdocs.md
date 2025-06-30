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
| [azurerm_monitor_activity_log_alert.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_activity_log_alert) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_action_group_id"></a> [action\_group\_id](#input\_action\_group\_id) | ID of the action group to notify. | `string` | n/a | yes |
| <a name="input_criteria"></a> [criteria](#input\_criteria) | Criteria for the activity log alert | <pre>object({<br/>    category       = string<br/>    level          = string<br/>    service_health = optional(object({<br/>      events    = list(string)<br/>      locations = list(string)<br/>      services  = optional(list(string))<br/>    }))<br/>  })</pre> | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | Description of the alert. | `string` | `"Activity log alert for Service Health events"` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | n/a | `bool` | `true` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region where the activity log alert is deployed (any valid region). | `string` | `"UK South"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the activity log alert. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group name. | `string` | n/a | yes |
| <a name="input_scopes"></a> [scopes](#input\_scopes) | List of scopes (usually one or more subscription IDs). | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(string)` | `{}` | no |
| <a name="input_webhook_properties"></a> [webhook\_properties](#input\_webhook\_properties) | n/a | `map(string)` | `{}` | no |

## Outputs

No outputs.
