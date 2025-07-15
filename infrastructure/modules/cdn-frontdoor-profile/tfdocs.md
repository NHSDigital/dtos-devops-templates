# Module documentation

## Required Inputs

The following input variables are required:

### <a name="input_name"></a> [name](#input\_name)

Description: Name of the Azure CDN Front Door Profile

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: n/a

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_certificate_secrets"></a> [certificate\_secrets](#input\_certificate\_secrets)

Description: List of cdn\_frontdoor\_secret resources to create and bind to the Front Door profile. The key may be used by Custom Domain configs in each project, the value is a Key Vault Certificate versionless\_id.

Type: `map(string)`

Default: `{}`

### <a name="input_identity"></a> [identity](#input\_identity)

Description: Optional identity which the Front Door profile can use to connect to other resources, for instance the target resources it will present. Not necessary for Key Vault Certificate interactions. See https://learn.microsoft.com/en-us/azure/frontdoor/standard-premium/how-to-configure-https-custom-domain?tabs=powershell#register-azure-front-door

Type:

```hcl
object({
    type         = string                 # "SystemAssigned", "UserAssigned", or "SystemAssigned, UserAssigned".
    identity_ids = optional(list(string)) # only required if using UserAssigned identity
  })
```

Default: `null`

### <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id)

Description: id of the log analytics workspace to send resource logging to via diagnostic settings. If omitted, Diagnostic Settings will not be enabled.

Type: `string`

Default: `null`

### <a name="input_metric_enabled"></a> [metric\_enabled](#input\_metric\_enabled)

Description: Enables retention for diagnostic settings metric

Type: `bool`

Default: `true`

### <a name="input_monitor_diagnostic_setting_frontdoor_enabled_logs"></a> [monitor\_diagnostic\_setting\_frontdoor\_enabled\_logs](#input\_monitor\_diagnostic\_setting\_frontdoor\_enabled\_logs)

Description: Controls which logs will be enabled for the Front Door profile

Type: `list(string)`

Default:

```json
[
  "FrontDoorAccessLog",
  "FrontDoorHealthProbeLog",
  "FrontDoorWebApplicationFirewallLog"
]
```

### <a name="input_monitor_diagnostic_setting_frontdoor_metrics"></a> [monitor\_diagnostic\_setting\_frontdoor\_metrics](#input\_monitor\_diagnostic\_setting\_frontdoor\_metrics)

Description: Controls which metrics will be enabled for the Front Door profile

Type: `list(string)`

Default:

```json
[
  "AllMetrics"
]
```

### <a name="input_response_timeout_seconds"></a> [response\_timeout\_seconds](#input\_response\_timeout\_seconds)

Description: Response timeout in seconds for the CDN Front Door Profile

Type: `number`

Default: `null`

### <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name)

Description: SKU name for the Azure CDN Front Door Profile (e.g., Standard\_AzureFrontDoor or Premium\_AzureFrontDoor). Premium is required for endpoints using private networking.

Type: `string`

Default: `"Standard_AzureFrontDoor"`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: Resource tags to be applied throughout the deployment.

Type: `map(string)`

Default: `{}`
## Modules

The following Modules are called:

### <a name="module_diagnostic-settings"></a> [diagnostic-settings](#module\_diagnostic-settings)

Source: ../diagnostic-settings

Version:
## Outputs

The following outputs are exported:

### <a name="output_id"></a> [id](#output\_id)

Description: n/a

### <a name="output_resource_guid"></a> [resource\_guid](#output\_resource\_guid)

Description: n/a

### <a name="output_secrets"></a> [secrets](#output\_secrets)

Description: n/a

### <a name="output_system_assigned_identity"></a> [system\_assigned\_identity](#output\_system\_assigned\_identity)

Description: n/a
## Resources

The following resources are used by this module:

- [azurerm_cdn_frontdoor_profile.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_profile) (resource)
- [azurerm_cdn_frontdoor_secret.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_secret) (resource)
