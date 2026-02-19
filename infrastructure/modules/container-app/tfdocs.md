# Module documentation

## Required Inputs

The following input variables are required:

### <a name="input_container_app_environment_id"></a> [container\_app\_environment\_id](#input\_container\_app\_environment\_id)

Description: ID of the container app environment.

Type: `string`

### <a name="input_docker_image"></a> [docker\_image](#input\_docker\_image)

Description: Docker image and tag. Format: <registry>/<repository>:<tag>

Type: `string`

### <a name="input_name"></a> [name](#input\_name)

Description: Name of the container app. Limited to 32 characters

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: Name of the resource group to create the container app in.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_acr_login_server"></a> [acr\_login\_server](#input\_acr\_login\_server)

Description: Container registry server. Required if using a private registry.

Type: `string`

Default: `null`

### <a name="input_acr_managed_identity_id"></a> [acr\_managed\_identity\_id](#input\_acr\_managed\_identity\_id)

Description: Managed identity ID for the container registry. Required if using a private registry.

Type: `string`

Default: `null`

### <a name="input_action_group_id"></a> [action\_group\_id](#input\_action\_group\_id)

Description: ID of the action group to notify.

Type: `string`

Default: `null`

### <a name="input_alert_cpu_threshold"></a> [alert\_cpu\_threshold](#input\_alert\_cpu\_threshold)

Description: If alerting is enabled this will control what the cpu threshold will be, default will be 80.

Type: `number`

Default: `80`

### <a name="input_alert_memory_threshold"></a> [alert\_memory\_threshold](#input\_alert\_memory\_threshold)

Description: If alerting is enabled this will control what the memory threshold will be, default will be 80.

Type: `number`

Default: `80`

### <a name="input_alert_window_size"></a> [alert\_window\_size](#input\_alert\_window\_size)

Description: The period of time that is used to monitor alert activity e.g. PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H. The interval between checks is adjusted accordingly.

Type: `string`

Default: `"PT5M"`

### <a name="input_app_key_vault_id"></a> [app\_key\_vault\_id](#input\_app\_key\_vault\_id)

Description: ID of the key vault to store app secrets. Each secret is mapped to an environment variable. Required when fetch\_secrets\_from\_app\_key\_vault is true.

Type: `string`

Default: `null`

### <a name="input_auth_excluded_paths"></a> [auth\_excluded\_paths](#input\_auth\_excluded\_paths)

Description: List of paths to exclude from authentication (e.g., ["/healthcheck", "/sha"]). These paths will respond without requiring authentication.

Type: `list(string)`

Default: `[]`

### <a name="input_enable_alerting"></a> [enable\_alerting](#input\_enable\_alerting)

Description: Whether monitoring and alerting is enabled for the PostgreSQL Flexible Server.

Type: `bool`

Default: `false`

### <a name="input_enable_entra_id_authentication"></a> [enable\_entra\_id\_authentication](#input\_enable\_entra\_id\_authentication)

Description: Enable authentication for the container app. If true, the app will use Entra ID authentication to restrict web access.

Type: `bool`

Default: `false`

### <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables)

Description: Environment variables to pass to the container app. Only non-secret variables. Secrets can be stored in key vault 'app\_key\_vault\_id'

Type: `map(string)`

Default: `{}`

### <a name="input_exposed_port"></a> [exposed\_port](#input\_exposed\_port)

Description: Externally exposed port for ingress. Default is var.port.

Type: `number`

Default: `null`

### <a name="input_fetch_secrets_from_app_key_vault"></a> [fetch\_secrets\_from\_app\_key\_vault](#input\_fetch\_secrets\_from\_app\_key\_vault)

Description:     Fetch secrets from the app key vault and map them to secret environment variables. Requires app\_key\_vault\_id.

    WARNING: The key vault must be created by terraform and populated manually before setting this to true.

Type: `bool`

Default: `false`

### <a name="input_infra_key_vault_name"></a> [infra\_key\_vault\_name](#input\_infra\_key\_vault\_name)

Description: Name of Key Vault to retrieve the AAD client secrets

Type: `string`

Default: `null`

### <a name="input_infra_key_vault_rg"></a> [infra\_key\_vault\_rg](#input\_infra\_key\_vault\_rg)

Description: Resource group of the Key Vault

Type: `string`

Default: `null`

### <a name="input_infra_secret_names"></a> [infra\_secret\_names](#input\_infra\_secret\_names)

Description: List of secret names to fetch from the infra key vault. Used to fetch AAD client secrets.

Type: `list(string)`

Default:

```json
[
  "aad-client-id",
  "aad-client-secret",
  "aad-client-audiences"
]
```

### <a name="input_is_tcp_app"></a> [is\_tcp\_app](#input\_is\_tcp\_app)

Description: Is this a TCP app? If true, ingress is enabled.

Type: `bool`

Default: `false`

### <a name="input_is_web_app"></a> [is\_web\_app](#input\_is\_web\_app)

Description: Is this a web app? If true, ingress is enabled.

Type: `bool`

Default: `false`

### <a name="input_location"></a> [location](#input\_location)

Description: The location/region where the container app is created.

Type: `string`

Default: `"UK South"`

### <a name="input_memory"></a> [memory](#input\_memory)

Description: Memory allocated to the app (GiB). Also dictates the CPU allocation: CPU(%)=MEMORY(Gi)/2. Maximum: 4Gi

Type: `number`

Default: `"0.5"`

### <a name="input_min_replicas"></a> [min\_replicas](#input\_min\_replicas)

Description: Minimum number of running containers (replicas). Replicas can scale from 0 to many depending on auto scaling rules (TBD)

Type: `number`

Default: `1`

### <a name="input_port"></a> [port](#input\_port)

Description: Internal port for ingress. Default is 8080.

Type: `number`

Default: `8080`

### <a name="input_probe_path"></a> [probe\_path](#input\_probe\_path)

Description: Path for the HTTP health probe. If null, HTTP health probe is disabled. Note /healthcheck is the normal convention.

Type: `string`

Default: `null`

### <a name="input_replica_restart_alert_threshold"></a> [replica\_restart\_alert\_threshold](#input\_replica\_restart\_alert\_threshold)

Description: The replica restart alert threshold, default will be 1.

Type: `number`

Default: `1`

### <a name="input_secret_variables"></a> [secret\_variables](#input\_secret\_variables)

Description: Secret environment variables to pass to the container app.

Type: `map(string)`

Default: `{}`

### <a name="input_unauthenticated_action"></a> [unauthenticated\_action](#input\_unauthenticated\_action)

Description: Action for unauthenticated requests: RedirectToLoginPage, Return401, Return403, AllowAnonymous

Type: `string`

Default: `"RedirectToLoginPage"`

### <a name="input_user_assigned_identity_ids"></a> [user\_assigned\_identity\_ids](#input\_user\_assigned\_identity\_ids)

Description: List of user assigned identity IDs to assign to the container app.

Type: `list(string)`

Default: `[]`

### <a name="input_workload_profile_name"></a> [workload\_profile\_name](#input\_workload\_profile\_name)

Description: Workload profile in this container app environment

Type: `string`

Default: `"Consumption"`
## Modules

The following Modules are called:

### <a name="module_container_app_identity"></a> [container\_app\_identity](#module\_container\_app\_identity)

Source: ../managed-identity

Version:

### <a name="module_key_vault_reader_role_app"></a> [key\_vault\_reader\_role\_app](#module\_key\_vault\_reader\_role\_app)

Source: ../rbac-assignment

Version:

### <a name="module_key_vault_reader_role_infra"></a> [key\_vault\_reader\_role\_infra](#module\_key\_vault\_reader\_role\_infra)

Source: ../rbac-assignment

Version:
## Outputs

The following outputs are exported:

### <a name="output_container_app_fqdn"></a> [container\_app\_fqdn](#output\_container\_app\_fqdn)

Description: n/a

### <a name="output_fqdn"></a> [fqdn](#output\_fqdn)

Description: FQDN of the container app. Only available if is\_web\_app is true.

### <a name="output_url"></a> [url](#output\_url)

Description: URL of the container app. Only available if is\_web\_app is true.
## Resources

The following resources are used by this module:

- [azapi_resource.auth](https://registry.terraform.io/providers/azure/azapi/2.5.0/docs/resources/resource) (resource)
- [azurerm_container_app.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app) (resource)
- [azurerm_monitor_metric_alert.cpu](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) (resource)
- [azurerm_monitor_metric_alert.memory](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) (resource)
- [azurerm_monitor_metric_alert.replica_restart_alert](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) (resource)
- [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) (data source)
- [azurerm_key_vault.infra](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault) (data source)
- [azurerm_key_vault_secret.infra](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) (data source)
- [azurerm_key_vault_secrets.app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secrets) (data source)
