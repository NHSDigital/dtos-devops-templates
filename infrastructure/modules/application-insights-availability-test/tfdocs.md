# Module documentation

## Required Inputs

The following input variables are required:

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


## Resources

The following resources are used by this module:

- [azurerm_application_insights_standard_web_test.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights_standard_web_test) (resource)
