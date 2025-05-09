# container-app

Deploy an [Azure container app](https://learn.microsoft.com/en-us/azure/container-apps/overview) to a [Container app environment](https://learn.microsoft.com/en-us/azure/container-apps/environment). Integrates with the [container-app-environment module](../container-app-environment/).

## Terraform documentation
For the list of inputs, outputs, resources... check the [terraform module documentation](tfdocs.md).

## Usage
```hcl
# Create the common container app environment
module "container-app-environment" {
  source = "../../../dtos-devops-templates/infrastructure/modules/container-app-environment"

  name                       = "manage-breast-screening-${var.environment}"
  resource_group_name        = azurerm_resource_group.this.name
  log_analytics_workspace_id = data.terraform_remote_state.audit.outputs.log_analytics_workspace_id
  vnet_integration_subnet_id = module.container_app_subnet.id
}

# Create a webapp for a container listening on port 8000
# The webapp will be available on internal URL https://<name>.<container app environment default domain>
module "webapp" {
  source                       = "../../../modules/dtos-devops-templates/infrastructure/modules/container-app"
  name                         = "manage-breast-screening-web-${var.environment}"
  container_app_environment_id = module.container-app-environment.id
  resource_group_name          = azurerm_resource_group.this.name
  app_key_vault_name           = module.app-key-vault.name # All secrets in the app key vault are mapped securely as environment variables
  docker_image                 = var.docker_image # Docker image and unique tag
  # Map of non secret environment variables
  environment_variables = {
    "ALLOWED_HOSTS" = "manage-breast-screening-web-${var.environment}.${module.container-app-environment.default_domain}"
  }
  is_web_app = true
  http_port  = 8000
}

# Create a background worker (no ingress)
module "worker" {
  source                       = "../../../modules/dtos-devops-templates/infrastructure/modules/container-app"
  name                         = "manage-breast-screening-worker-${var.environment}"
  container_app_environment_id = module.container-app-environment.id
  resource_group_name          = azurerm_resource_group.this.name
  app_key_vault_name           = module.app-key-vault.name
  docker_image                 = var.docker_image_worker
}
```
