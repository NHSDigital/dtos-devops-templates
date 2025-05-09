# Module documentation

## Required Inputs

The following input variables are required:

### <a name="input_dag_name"></a> [dag\_name](#input\_dag\_name)

Description: The name of the AVD Desktop Application Group (DAG)

Type: `string`

### <a name="input_entra_admins_group_id"></a> [entra\_admins\_group\_id](#input\_entra\_admins\_group\_id)

Description: n/a

Type: `string`

### <a name="input_entra_users_group_id"></a> [entra\_users\_group\_id](#input\_entra\_users\_group\_id)

Description: n/a

Type: `string`

### <a name="input_host_pool_name"></a> [host\_pool\_name](#input\_host\_pool\_name)

Description: The name of the AVD host pool

Type: `string`

### <a name="input_location"></a> [location](#input\_location)

Description: n/a

Type: `string`

### <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id)

Description: The id of the resource group in which to create the Azure Virtual Desktop.

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The name of the resource group in which to create the Azure Virtual Desktop.

Type: `string`

### <a name="input_scaling_plan_name"></a> [scaling\_plan\_name](#input\_scaling\_plan\_name)

Description: The name of the AVD scaling plan

Type: `string`

### <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id)

Description: The subnet id which will contain the AVD session host.

Type: `string`

### <a name="input_vm_license_type"></a> [vm\_license\_type](#input\_vm\_license\_type)

Description: n/a

Type: `string`

### <a name="input_vm_name_prefix"></a> [vm\_name\_prefix](#input\_vm\_name\_prefix)

Description: n/a

Type: `string`

### <a name="input_workspace_name"></a> [workspace\_name](#input\_workspace\_name)

Description: The name of the AVD workspace

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_computer_name_prefix"></a> [computer\_name\_prefix](#input\_computer\_name\_prefix)

Description: n/a

Type: `string`

Default: `"avd"`

### <a name="input_custom_rdp_properties"></a> [custom\_rdp\_properties](#input\_custom\_rdp\_properties)

Description: n/a

Type: `string`

Default: `null`

### <a name="input_dag_default_desktop_display_name"></a> [dag\_default\_desktop\_display\_name](#input\_dag\_default\_desktop\_display\_name)

Description: n/a

Type: `string`

Default: `"SessionDesktop"`

### <a name="input_dag_description"></a> [dag\_description](#input\_dag\_description)

Description: n/a

Type: `string`

Default: `null`

### <a name="input_dag_friendly_name"></a> [dag\_friendly\_name](#input\_dag\_friendly\_name)

Description: n/a

Type: `string`

Default: `null`

### <a name="input_dag_type"></a> [dag\_type](#input\_dag\_type)

Description: n/a

Type: `string`

Default: `"Desktop"`

### <a name="input_host_pool_description"></a> [host\_pool\_description](#input\_host\_pool\_description)

Description: n/a

Type: `string`

Default: `null`

### <a name="input_host_pool_friendly_name"></a> [host\_pool\_friendly\_name](#input\_host\_pool\_friendly\_name)

Description: n/a

Type: `string`

Default: `null`

### <a name="input_host_pool_type"></a> [host\_pool\_type](#input\_host\_pool\_type)

Description: n/a

Type: `string`

Default: `"Pooled"`

### <a name="input_load_balancer_type"></a> [load\_balancer\_type](#input\_load\_balancer\_type)

Description: n/a

Type: `string`

Default: `"BreadthFirst"`

### <a name="input_maximum_sessions_allowed"></a> [maximum\_sessions\_allowed](#input\_maximum\_sessions\_allowed)

Description: n/a

Type: `number`

Default: `16`

### <a name="input_source_image_from_gallery"></a> [source\_image\_from\_gallery](#input\_source\_image\_from\_gallery)

Description: n/a

Type:

```hcl
object({
    image_name      = string
    gallery_name    = string
    gallery_rg_name = string
  })
```

Default: `null`

### <a name="input_source_image_id"></a> [source\_image\_id](#input\_source\_image\_id)

Description: The resource id of an OS image, possibly in a remote subscription. Remember to grant 'Compute Gallery Image Reader' RBAC role.

Type: `string`

Default: `null`

### <a name="input_source_image_reference"></a> [source\_image\_reference](#input\_source\_image\_reference)

Description: n/a

Type:

```hcl
object({
    offer     = string
    publisher = string
    sku       = string
    version   = string
  })
```

Default: `null`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: A map of tags to assign to the resource.

Type: `map(string)`

Default: `{}`

### <a name="input_validate_environment"></a> [validate\_environment](#input\_validate\_environment)

Description: Validation host pool allows you to test service changes before they are deployed to production.

Type: `bool`

Default: `false`

### <a name="input_vm_count"></a> [vm\_count](#input\_vm\_count)

Description: n/a

Type: `number`

Default: `1`

### <a name="input_vm_disk_size"></a> [vm\_disk\_size](#input\_vm\_disk\_size)

Description: The OS disk size in GB.

Type: `number`

Default: `128`

### <a name="input_vm_size"></a> [vm\_size](#input\_vm\_size)

Description: n/a

Type: `string`

Default: `"Standard_D2as_v5"`

### <a name="input_vm_storage_account_type"></a> [vm\_storage\_account\_type](#input\_vm\_storage\_account\_type)

Description: n/a

Type: `string`

Default: `"StandardSSD_LRS"`

### <a name="input_workspace_description"></a> [workspace\_description](#input\_workspace\_description)

Description: n/a

Type: `string`

Default: `null`

### <a name="input_workspace_friendly_name"></a> [workspace\_friendly\_name](#input\_workspace\_friendly\_name)

Description: n/a

Type: `string`

Default: `null`


## Resources

The following resources are used by this module:

- [azurerm_network_interface.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) (resource)
- [azurerm_role_assignment.dag_admins](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [azurerm_role_assignment.dag_users](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [azurerm_role_assignment.rg_admins](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [azurerm_role_assignment.rg_users](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [azurerm_virtual_desktop_application_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_desktop_application_group) (resource)
- [azurerm_virtual_desktop_host_pool.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_desktop_host_pool) (resource)
- [azurerm_virtual_desktop_host_pool_registration_info.registrationinfo](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_desktop_host_pool_registration_info) (resource)
- [azurerm_virtual_desktop_scaling_plan.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_desktop_scaling_plan) (resource)
- [azurerm_virtual_desktop_workspace.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_desktop_workspace) (resource)
- [azurerm_virtual_desktop_workspace_application_group_association.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_desktop_workspace_application_group_association) (resource)
- [azurerm_virtual_machine_extension.aadjoin](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) (resource)
- [azurerm_virtual_machine_extension.azurepolicy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) (resource)
- [azurerm_virtual_machine_extension.guestattestation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) (resource)
- [azurerm_virtual_machine_extension.hostpooljoin](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) (resource)
- [azurerm_windows_virtual_machine.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine) (resource)
- [random_password.admin_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) (resource)
- [random_string.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) (resource)
- [azurerm_shared_image.gallery_image](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/shared_image) (data source)
