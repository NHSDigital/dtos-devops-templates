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

### <a name="input_app_key_vault_name"></a> [app\_key\_vault\_name](#input\_app\_key\_vault\_name)

Description: Name of the key vault to store app secret. Each secret is mapped to an environment variable.

Type: `string`

Default: `null`

### <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables)

Description: Environment variables to pass to the container app. Only non-secret variables. Secrets must be stored in key vault 'app\_key\_vault\_name'

Type: `map(string)`

Default: `{}`

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


## Resources

The following resources are used by this module:

- [azurerm_container_app.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app) (resource)
- [azurerm_role_assignment.key_vault_reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [azurerm_key_vault.app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault) (data source)
- [azurerm_key_vault_secrets.app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secrets) (data source)
