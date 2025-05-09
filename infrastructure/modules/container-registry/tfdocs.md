# Module documentation

## Required Inputs

The following input variables are required:

### <a name="input_admin_enabled"></a> [admin\_enabled](#input\_admin\_enabled)

Description: Specifies whether the admin user is enabled.

Type: `string`

### <a name="input_location"></a> [location](#input\_location)

Description: The location/region where the ACR is created.

Type: `string`

### <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id)

Description: id of the log analytics workspace to send resource logging to via diagnostic settings

Type: `string`

### <a name="input_monitor_diagnostic_setting_acr_enabled_logs"></a> [monitor\_diagnostic\_setting\_acr\_enabled\_logs](#input\_monitor\_diagnostic\_setting\_acr\_enabled\_logs)

Description: Controls what logs will be enabled for the acr

Type: `list(string)`

### <a name="input_monitor_diagnostic_setting_acr_metrics"></a> [monitor\_diagnostic\_setting\_acr\_metrics](#input\_monitor\_diagnostic\_setting\_acr\_metrics)

Description: Controls what metrics will be enabled for the acr

Type: `list(string)`

### <a name="input_name"></a> [name](#input\_name)

Description: The Azure Container Registry name.

Type: `string`

### <a name="input_private_endpoint_properties"></a> [private\_endpoint\_properties](#input\_private\_endpoint\_properties)

Description: Consolidated properties for the Function App Private Endpoint.

Type:

```hcl
object({
    private_dns_zone_ids                 = optional(list(string), [])
    private_endpoint_enabled             = optional(bool, false)
    private_endpoint_subnet_id           = optional(string, "")
    private_endpoint_resource_group_name = optional(string, "")
    private_service_connection_is_manual = optional(bool, false)
  })
```

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The name of the resource group in which to create the ACR. Changing this forces a new resource to be created.

Type: `string`

### <a name="input_sku"></a> [sku](#input\_sku)

Description: The SKU of the ACR.

Type: `string`

### <a name="input_uai_name"></a> [uai\_name](#input\_uai\_name)

Description: Name of the User Assigned Identity for ACR Push

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled)

Description: Controls whether the acr may be accessed from public networks.

Type: `bool`

Default: `false`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: Resource tags to be applied throughout the deployment.

Type: `map(string)`

Default: `{}`

### <a name="input_zone_redundancy_enabled"></a> [zone\_redundancy\_enabled](#input\_zone\_redundancy\_enabled)

Description: n/a

Type: `bool`

Default: `false`
## Modules

The following Modules are called:

### <a name="module_diagnostic-settings"></a> [diagnostic-settings](#module\_diagnostic-settings)

Source: ../diagnostic-settings

Version:

### <a name="module_private_endpoint_container_registry"></a> [private\_endpoint\_container\_registry](#module\_private\_endpoint\_container\_registry)

Source: ../private-endpoint

Version:
## Outputs

The following outputs are exported:

### <a name="output_login_server"></a> [login\_server](#output\_login\_server)

Description: n/a

### <a name="output_mi_client_id"></a> [mi\_client\_id](#output\_mi\_client\_id)

Description: n/a

### <a name="output_mi_id"></a> [mi\_id](#output\_mi\_id)

Description: n/a
## Resources

The following resources are used by this module:

- [azurerm_container_registry.acr](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry) (resource)
- [azurerm_role_assignment.ra](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [azurerm_user_assigned_identity.uai](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) (resource)
