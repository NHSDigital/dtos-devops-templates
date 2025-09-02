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

### <a name="input_container_args"></a> [container\_args](#input\_container\_args)

Description: The arguments to pass to the container command. Optional.

Type: `list(string)`

Default: `null`

### <a name="input_container_command"></a> [container\_command](#input\_container\_command)

Description: The commands to execute in the container. Optional.

Type: `list(string)`

Default: `null`

### <a name="input_cron_expression"></a> [cron\_expression](#input\_cron\_expression)

Description: Cron formatted repeating schedule of a Cron Job eg. '0 5 * * *'. Optional.

Type: `string`

Default: `null`

### <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables)

Description: Environment variables to pass to the container app. Only non-secret variables. Secrets must be stored in key vault 'app\_key\_vault\_id'

Type: `map(string)`

Default: `{}`

### <a name="input_job_parallelism"></a> [job\_parallelism](#input\_job\_parallelism)

Description: The number of replicas that can run in parallel.

Type: `number`

Default: `1`

### <a name="input_location"></a> [location](#input\_location)

Description: The location/region where the container app environment is created.

Type: `string`

Default: `"UK South"`

### <a name="input_memory"></a> [memory](#input\_memory)

Description: Memory allocated to the app (GiB). Also dictates the CPU allocation: CPU(%)=MEMORY(Gi)/2. Maximum: 4Gi

Type: `number`

Default: `"0.5"`

### <a name="input_polling_interval_in_seconds"></a> [polling\_interval\_in\_seconds](#input\_polling\_interval\_in\_seconds)

Description: Interval to check each event source in seconds.

Type: `number`

Default: `300`

### <a name="input_replica_completion_count"></a> [replica\_completion\_count](#input\_replica\_completion\_count)

Description: The number of replicas that must complete successfully for the job to be considered successful.

Type: `number`

Default: `1`

### <a name="input_replica_retry_limit"></a> [replica\_retry\_limit](#input\_replica\_retry\_limit)

Description: The number of retries allowed for a replica in case of failure.

Type: `number`

Default: `3`

### <a name="input_replica_timeout_in_seconds"></a> [replica\_timeout\_in\_seconds](#input\_replica\_timeout\_in\_seconds)

Description: The timeout in seconds for a replica to complete execution.

Type: `number`

Default: `300`

### <a name="input_scale_rule_metadata"></a> [scale\_rule\_metadata](#input\_scale\_rule\_metadata)

Description: Metadata properties to describe the scale rule. Refer to [KEDA scaler documentation](https://keda.sh/docs/2.17/scalers/) for metadata relevant to the scale rule.

Type: `map(string)`

Default: `{}`

### <a name="input_scale_rule_type"></a> [scale\_rule\_type](#input\_scale\_rule\_type)

Description: Type of scale rule for the event trigger. See [KEDA scaler documentation](https://keda.sh/docs/2.17/scalers/) for supported types.

Type: `string`

Default: `null`

### <a name="input_user_assigned_identity_ids"></a> [user\_assigned\_identity\_ids](#input\_user\_assigned\_identity\_ids)

Description: List of user assigned identity IDs to assign to the container app.

Type: `list(string)`

Default: `[]`

### <a name="input_workload_profile_name"></a> [workload\_profile\_name](#input\_workload\_profile\_name)

Description: Workload profile in this container app environment

Type: `string`

Default: `"Consumption"`


## Resources

The following resources are used by this module:

- [azurerm_container_app_job.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app_job) (resource)
