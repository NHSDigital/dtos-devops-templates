# Module documentation

## Required Inputs

The following input variables are required:

### <a name="input_acr_login_server"></a> [acr\_login\_server](#input\_acr\_login\_server)

Description: The login server for the Azure Container Registry.

Type: `string`

### <a name="input_ai_connstring"></a> [ai\_connstring](#input\_ai\_connstring)

Description: The App Insights connection string.

Type: `string`

### <a name="input_app_service_logs_disk_quota_mb"></a> [app\_service\_logs\_disk\_quota\_mb](#input\_app\_service\_logs\_disk\_quota\_mb)

Description: The amount of disk space to use for app service logs.

Type: `number`

### <a name="input_app_service_logs_retention_period_days"></a> [app\_service\_logs\_retention\_period\_days](#input\_app\_service\_logs\_retention\_period\_days)

Description: The retention period for logs in days.

Type: `number`

### <a name="input_asp_id"></a> [asp\_id](#input\_asp\_id)

Description: The ID of the AppServicePlan.

Type: `string`

### <a name="input_function_app_name"></a> [function\_app\_name](#input\_function\_app\_name)

Description: Name of the Function App

Type: `string`

### <a name="input_image_name"></a> [image\_name](#input\_image\_name)

Description: Name of the docker image

Type: `any`

### <a name="input_image_tag"></a> [image\_tag](#input\_image\_tag)

Description: Tag of the docker image

Type: `any`

### <a name="input_location"></a> [location](#input\_location)

Description: The location/region where the Function App is created.

Type: `string`

### <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id)

Description: id of the log analytics workspace to send resource logging to via diagnostic settings

Type: `string`

### <a name="input_monitor_diagnostic_setting_function_app_enabled_logs"></a> [monitor\_diagnostic\_setting\_function\_app\_enabled\_logs](#input\_monitor\_diagnostic\_setting\_function\_app\_enabled\_logs)

Description: Controls what logs will be enabled for the function app

Type: `list(string)`

### <a name="input_monitor_diagnostic_setting_function_app_metrics"></a> [monitor\_diagnostic\_setting\_function\_app\_metrics](#input\_monitor\_diagnostic\_setting\_function\_app\_metrics)

Description: Controls what metrics will be enabled for the function app

Type: `list(string)`

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

Description: The name of the resource group in which to create the Function App. Changing this forces a new resource to be created.

Type: `string`

### <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name)

Description: The name of the Storage Account.

Type: `string`

### <a name="input_worker_32bit"></a> [worker\_32bit](#input\_worker\_32bit)

Description: Should the Windows Function App use a 32-bit worker process. Defaults to true

Type: `bool`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_acr_mi_client_id"></a> [acr\_mi\_client\_id](#input\_acr\_mi\_client\_id)

Description: The Managed Identity Id for the Azure Container Registry.

Type: `any`

Default: `null`

### <a name="input_always_on"></a> [always\_on](#input\_always\_on)

Description: Should the Function App be always on. Override standard default.

Type: `bool`

Default: `true`

### <a name="input_app_settings"></a> [app\_settings](#input\_app\_settings)

Description: Map of values for the app settings

Type: `map`

Default: `{}`

### <a name="input_assigned_identity_ids"></a> [assigned\_identity\_ids](#input\_assigned\_identity\_ids)

Description: The list of User Assigned Identity IDs to assign to the Function App.

Type: `list(string)`

Default: `[]`

### <a name="input_cont_registry_use_mi"></a> [cont\_registry\_use\_mi](#input\_cont\_registry\_use\_mi)

Description: Should connections for Azure Container Registry use Managed Identity.

Type: `bool`

Default: `false`

### <a name="input_cors_allowed_origins"></a> [cors\_allowed\_origins](#input\_cors\_allowed\_origins)

Description: n/a

Type: `list(string)`

Default:

```json
[
  ""
]
```

### <a name="input_entra_id_group_ids"></a> [entra\_id\_group\_ids](#input\_entra\_id\_group\_ids)

Description: n/a

Type: `list(string)`

Default: `[]`

### <a name="input_ftp_publish_basic_authentication_enabled"></a> [ftp\_publish\_basic\_authentication\_enabled](#input\_ftp\_publish\_basic\_authentication\_enabled)

Description: Enable basic authentication for FTP. Defaults to false.

Type: `bool`

Default: `false`

### <a name="input_ftps_state"></a> [ftps\_state](#input\_ftps\_state)

Description: Enable FTPS enforcement for enhanced security. Allowed values = AllAllowed (i.e. FTP & FTPS), FtpsOnly and Disabled (i.e. no FTP/FTPS access). Defaults to AllAllowed.

Type: `string`

Default: `"Disabled"`

### <a name="input_function_app_slots"></a> [function\_app\_slots](#input\_function\_app\_slots)

Description: function app slots

Type:

```hcl
list(object({
    function_app_slots_name   = optional(string, "staging")
    function_app_slot_enabled = optional(bool, false)
  }))
```

Default: `[]`

### <a name="input_health_check_eviction_time_in_min"></a> [health\_check\_eviction\_time\_in\_min](#input\_health\_check\_eviction\_time\_in\_min)

Description: The time in minutes a node can be unhealthy before being removed from the load balancer.

Type: `number`

Default: `null`

### <a name="input_health_check_path"></a> [health\_check\_path](#input\_health\_check\_path)

Description: The path to be checked for this function app health.

Type: `string`

Default: `null`

### <a name="input_http2_enabled"></a> [http2\_enabled](#input\_http2\_enabled)

Description: Specifies whether or not the HTTP2 protocol should be enabled. Defaults to false

Type: `bool`

Default: `false`

### <a name="input_http_version"></a> [http\_version](#input\_http\_version)

Description: The HTTP version to use for the function app. Override standard default.

Type: `string`

Default: `"2.0"`

### <a name="input_https_only"></a> [https\_only](#input\_https\_only)

Description: Can the Function App only be accessed via HTTPS? Override standard default.

Type: `bool`

Default: `true`

### <a name="input_ip_restriction_default_action"></a> [ip\_restriction\_default\_action](#input\_ip\_restriction\_default\_action)

Description: Default action for FW rules

Type: `string`

Default: `"Deny"`

### <a name="input_ip_restrictions"></a> [ip\_restrictions](#input\_ip\_restrictions)

Description: n/a

Type:

```hcl
map(object({
    headers = optional(list(object({
      x_azure_fdid      = optional(list(string))
      x_fd_health_probe = optional(list(string))
      x_forwarded_for   = optional(list(string))
      x_forwarded_host  = optional(list(string))
    })), [])
    ip_address                = optional(string)
    name                      = optional(string)
    priority                  = optional(number)
    action                    = optional(string, "Deny")
    service_tag               = optional(string)
    virtual_network_subnet_id = optional(string)
  }))
```

Default: `{}`

### <a name="input_minimum_tls_version"></a> [minimum\_tls\_version](#input\_minimum\_tls\_version)

Description: n/a

Type: `string`

Default: `"1.2"`

### <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled)

Description: Should the Function App be accessible from the public network. Override standard default.

Type: `bool`

Default: `false`

### <a name="input_rbac_role_assignments"></a> [rbac\_role\_assignments](#input\_rbac\_role\_assignments)

Description: Map of RBAC role assignments by region

Type:

```hcl
list(object({
    role_definition_name = string
    scope                = string
  }))
```

Default: `[]`

### <a name="input_storage_account_access_key"></a> [storage\_account\_access\_key](#input\_storage\_account\_access\_key)

Description: The Storage Account Primary Access Key.

Type: `string`

Default: `null`

### <a name="input_storage_uses_managed_identity"></a> [storage\_uses\_managed\_identity](#input\_storage\_uses\_managed\_identity)

Description: Should the Storage Account use a Managed Identity. Defaults to false.

Type: `bool`

Default: `false`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: Resource tags to be applied throughout the deployment.

Type: `map(string)`

Default: `{}`

### <a name="input_vnet_integration_subnet_id"></a> [vnet\_integration\_subnet\_id](#input\_vnet\_integration\_subnet\_id)

Description: The ID of the subnet to integrate the Function App with.

Type: `string`

Default: `null`

### <a name="input_webdeploy_publish_basic_authentication_enabled"></a> [webdeploy\_publish\_basic\_authentication\_enabled](#input\_webdeploy\_publish\_basic\_authentication\_enabled)

Description: Enable basic authentication for WebDeploy. Override standard default.

Type: `bool`

Default: `false`
## Modules

The following Modules are called:

### <a name="module_diagnostic-settings"></a> [diagnostic-settings](#module\_diagnostic-settings)

Source: ../diagnostic-settings

Version:

### <a name="module_function_app_slots"></a> [function\_app\_slots](#module\_function\_app\_slots)

Source: ../function-app-slots

Version:

### <a name="module_private_endpoint"></a> [private\_endpoint](#module\_private\_endpoint)

Source: ../private-endpoint

Version:

### <a name="module_rbac_assignments"></a> [rbac\_assignments](#module\_rbac\_assignments)

Source: ../rbac-assignment

Version:
## Outputs

The following outputs are exported:

### <a name="output_function_app_endpoint_name"></a> [function\_app\_endpoint\_name](#output\_function\_app\_endpoint\_name)

Description: The function app endpoint name.

### <a name="output_function_app_sami_id"></a> [function\_app\_sami\_id](#output\_function\_app\_sami\_id)

Description: The Principal ID of the System Assigned Managed Service Identity that is configured on this Linux Function App.

### <a name="output_id"></a> [id](#output\_id)

Description: The id of the Linux Function App.

### <a name="output_name"></a> [name](#output\_name)

Description: The name of the Linux Function App.
## Resources

The following resources are used by this module:

- [azuread_group_member.function_app](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group_member) (resource)
- [azurerm_linux_function_app.function_app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_function_app) (resource)
