# Module documentation

## Required Inputs

The following input variables are required:

### <a name="input_action_group_id"></a> [action\_group\_id](#input\_action\_group\_id)

Description: ID of the action group to notify.

Type: `string`

### <a name="input_criteria"></a> [criteria](#input\_criteria)

Description: Criteria for the activity log alert

Type:

```hcl
object({
    category = string
    level    = string
    service_health = optional(object({
      events    = list(string)
      locations = list(string)
      services  = optional(list(string))
    }))
  })
```

### <a name="input_name"></a> [name](#input\_name)

Description: Name of the activity log alert.

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: Resource group name.

Type: `string`

### <a name="input_scopes"></a> [scopes](#input\_scopes)

Description: List of scopes (usually one or more subscription IDs).

Type: `list(string)`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_description"></a> [description](#input\_description)

Description: Description of the alert.

Type: `string`

Default: `"Activity log alert for Service Health events"`

### <a name="input_enabled"></a> [enabled](#input\_enabled)

Description: n/a

Type: `bool`

Default: `true`

### <a name="input_location"></a> [location](#input\_location)

Description: Azure region where the activity log alert is deployed (any valid region).

Type: `string`

Default: `"UK South"`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: n/a

Type: `map(string)`

Default: `{}`

### <a name="input_webhook_properties"></a> [webhook\_properties](#input\_webhook\_properties)

Description: n/a

Type: `map(string)`

Default: `{}`


## Resources

The following resources are used by this module:

- [azurerm_monitor_activity_log_alert.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_activity_log_alert) (resource)
