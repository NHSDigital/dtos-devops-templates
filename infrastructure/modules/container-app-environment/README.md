# container-app-environment

A [Container Apps environment](https://learn.microsoft.com/en-us/azure/container-apps/environment) is a secure boundary around one or more container apps and jobs. The Container Apps runtime manages each environment by handling OS upgrades, scale operations, failover procedures, and resource balancing.

Integrates with the [container-app module](../container-app/).

## Terraform documentation
For the list of inputs, outputs, resources... check the [terraform module documentation](tfdocs.md).

## Usage

```hcl
module "container-app-environment" {
  source = "../../../dtos-devops-templates/infrastructure/modules/container-app-environment"

  name                       = "manage-breast-screening-${var.environment}"
  resource_group_name        = azurerm_resource_group.this.name
  log_analytics_workspace_id = data.terraform_remote_state.audit.outputs.log_analytics_workspace_id
  vnet_integration_subnet_id = module.container_app_subnet.id
}
```
