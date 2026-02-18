# Module documentation

## Required Inputs

The following input variables are required:

### <a name="input_action_group_id"></a> [action\_group\_id](#input\_action\_group\_id)

Description: ID of the action group to notify.

Type: `string`

### <a name="input_application_insights_id"></a> [application\_insights\_id](#input\_application\_insights\_id)

Description: The Application Insights resource id to associate the availability test with

Type: `string`

### <a name="input_name"></a> [name](#input\_name)

Description: Name of the availability test, must be unique for the used application insights instance

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The name of the resource group in which to create the availability test.

Type: `string`

### <a name="input_target_url"></a> [target\_url](#input\_target\_url)

Description: The target URL for the restful endpoint to hit to validate the application is available

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_frequency"></a> [frequency](#input\_frequency)

Description: Frequency of test in seconds, defaults to 300.

Type: `number`

Default: `300`

### <a name="input_geo_locations"></a> [geo\_locations](#input\_geo\_locations)

Description: List of Azure test locations (provider-specific location strings for UK and Ireland)

Type: `list(string)`

Default:

```json
[
  "emea-ru-msa-edge",
  "emea-se-sto-edge",
  "emea-gb-db3-azr"
]
```

### <a name="input_location"></a> [location](#input\_location)

Description: The location/region where the availability test is deployed (must match App Insights location)

Type: `string`

Default: `"UK South"`

### <a name="input_timeout"></a> [timeout](#input\_timeout)

Description: Timeout in seconds, defaults to 30.

Type: `number`

Default: `30`

### <a name="input_http_verb"></a> [http_verb](#input\_http\_verb)

Description: The HTTP verb used for the request.

Type: `string`

Allowed values: GET, POST, PUT, PATCH, DELETE, HEAD, OPTIONS

Default: GET

### <a name="input_headers"></a> [headers](#input\_headers)

Description: A map of HTTP request headers (name => value).

Type: `map(string)`

Default: {}

### <a name="input_ssl_validation"></a> [ssl_validation](#input\_ssl\_validation)

Description: SSL validation configuration for the availability test.

Type:
```hcl
object({
  expected_status_code        = optional(number, null)
  ssl_cert_remaining_lifetime = optional(number, null)
})
```

Default: null

Validations:
- expected_status_code must be 0 ('0' means 'response code < 400') or a valid HTTP status code (100–599)
- ssl_cert_remaining_lifetime must be null or between 1–365

### <a name="input_alert"></a> [alert](#input\_alert)

Description: Configuration for the availability alert rule.

Type:
```hcl
object({
  description           = optional(string, "Availability test alert")
  frequency             = optional(string, "PT1M")
  window_size           = optional(string, "PT5M")
  auto_mitigate         = optional(bool, true)
})
```

Defaults: {}

Validations:
- frequency must be one of: PT1M, PT5M, PT15M, PT30M, PT1H
- window_size must be one of: PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H, P1D

## Resources

The following resources are used by this module:

- [azurerm_application_insights_standard_web_test.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights_standard_web_test) (resource)
- [azurerm_monitor_metric_alert.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) (resource)
