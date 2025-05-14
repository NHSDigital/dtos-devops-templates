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

### <a name="input_app_key_vault_id"></a> [app\_key\_vault\_id](#input\_app\_key\_vault\_id)

Description: ID of the key vault to store app secrets. Each secret is mapped to an environment variable. Required when fetch\_secrets\_from\_app\_key\_vault is true.

Type: `string`

Default: `null`

### <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables)

Description: Environment variables to pass to the container app. Only non-secret variables. Secrets must be stored in key vault 'app\_key\_vault\_id'

Type: `map(string)`

Default: `{}`

### <a name="input_fetch_secrets_from_app_key_vault"></a> [fetch\_secrets\_from\_app\_key\_vault](#input\_fetch\_secrets\_from\_app\_key\_vault)

Description:     Fetch secrets from the app key vault and map them to secret environment variables. Requires app\_key\_vault\_id.

    WARNING: The key vault must be created by terraform and populated manually before setting this to true.

Type: `bool`

Default: `false`

### <a name="input_http_port"></a> [http\_port](#input\_http\_port)

Description: HTTP port for the web app. Default is 8080.

Type: `number`

Default: `8080`

### <a name="input_is_web_app"></a> [is\_web\_app](#input\_is\_web\_app)

Description: Is this a web app? If true, ingress is enabled.

Type: `bool`

Default: `false`

### <a name="input_memory"></a> [memory](#input\_memory)

Description: Memory allocated to the app (GiB). Also dictates the CPU allocation: CPU(%)=MEMORY(Gi)/2. Maximum: 4Gi

Type: `number`

Default: `"0.5"`

### <a name="input_min_replicas"></a> [min\_replicas](#input\_min\_replicas)

Description: Minimum number of running containers (replicas). Replicas can scale from 0 to many depending on auto scaling rules (TBD)

Type: `number`

Default: `1`
## Modules

The following Modules are called:

### <a name="module_container_app_identity"></a> [container\_app\_identity](#module\_container\_app\_identity)

Source: ../managed-identity

Version:

### <a name="module_key_vault_reader_role"></a> [key\_vault\_reader\_role](#module\_key\_vault\_reader\_role)

Source: ../rbac-assignment

Version:
## Outputs

The following outputs are exported:

### <a name="output_url"></a> [url](#output\_url)

Description: URL of the container app. Only available if is\_web\_app is true.
## Resources

The following resources are used by this module:

- [azurerm_container_app.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app) (resource)
- [azurerm_key_vault_secrets.app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secrets) (data source)
- [azurerm_resource_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) (data source)
