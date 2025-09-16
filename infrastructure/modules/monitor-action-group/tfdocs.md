# Module documentation

## Required Inputs

The following input variables are required:

### <a name="input_location"></a> [location](#input\_location)

Description: The location/region where the Event Hub namespace is created.

Type: `string`

### <a name="input_name"></a> [name](#input\_name)

Description: value of the name of the diagnostic setting

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The name of the resource group in which to create the monitor action group.

Type: `string`

### <a name="input_short_name"></a> [short\_name](#input\_short\_name)

Description: The short name of the action group. This will be used in SMS messages.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_email_receiver"></a> [email\_receiver](#input\_email\_receiver)

Description: Email receiver properties.

Type:

```hcl
map(object({
    name                    = string
    email_address           = string
    use_common_alert_schema = optional(bool, false)
  }))
```

Default: `null`

### <a name="input_event_hub_receiver"></a> [event\_hub\_receiver](#input\_event\_hub\_receiver)

Description: event hub receiver properties.

Type:

```hcl
map(object({
    name                    = string
    event_hub_namespace     = string
    event_hub_name          = string
    subscription_id         = string
    use_common_alert_schema = bool
  }))
```

Default: `null`

### <a name="input_sms_receiver"></a> [sms\_receiver](#input\_sms\_receiver)

Description: sms receiver properties.

Type:

```hcl
map(object({
    name         = string
    country_code = string
    phone_number = string
  }))
```

Default: `null`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: A mapping of tags to assign to the resource.

Type: `map(string)`

Default: `{}`

### <a name="input_voice_receiver"></a> [voice\_receiver](#input\_voice\_receiver)

Description: voice receiver properties.

Type:

```hcl
map(object({
    name         = string
    country_code = string
    phone_number = string
  }))
```

Default: `null`

### <a name="input_webhook_receiver"></a> [webhook\_receiver](#input\_webhook\_receiver)

Description: webhook receiver properties.

Type:

```hcl
map(object({
    name                    = string
    service_uri             = string
    use_common_alert_schema = bool
  }))
```

Default: `null`

## Outputs

The following outputs are exported:

### <a name="output_monitor_action_group"></a> [monitor\_action\_group](#output\_monitor\_action\_group)

Description: n/a
## Resources

The following resources are used by this module:

- [azurerm_monitor_action_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_action_group) (resource)
