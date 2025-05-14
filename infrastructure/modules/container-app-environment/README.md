# container-app-environment

A [Container Apps environment](https://learn.microsoft.com/en-us/azure/container-apps/environment) is a secure boundary around one or more container apps and jobs. The Container Apps runtime manages each environment by handling OS upgrades, scale operations, failover procedures, and resource balancing.

Integrates with the [container-app module](../container-app/).

## Terraform documentation
For the list of inputs, outputs, resources... check the [terraform module documentation](tfdocs.md).

## Usage

```hcl
module "container-app-environment" {
  source = "../../../dtos-devops-templates/infrastructure/modules/container-app-environment"
  providers = {
    azurerm     = azurerm
    azurerm.dns = azurerm
  }

  name                       = "manage-breast-screening-${var.environment}"
  resource_group_name        = azurerm_resource_group.this.name
  log_analytics_workspace_id = module.log_analytics_workspace_audit.id
  vnet_integration_subnet_id = module.container_app_subnet.id
  private_dns_zone_rg_name   = var.private_dns_zone_rg_name
}
```

If the private DNS zone is located in a different subscription, for instance in a hub and spoke architecture, the provider of that subscription must be provided:

```hcl
provider "azurerm" {
  alias           = "hub"
  subscription_id = var.hub_subscription_id

  features {}
}

module "container-app-environment" {
  source = "../../../dtos-devops-templates/infrastructure/modules/container-app-environment"
  providers = {
    azurerm     = azurerm
    azurerm.dns = azurerm.hub
  }

  name                       = "manage-breast-screening-${var.environment}"
  ...
}
```
