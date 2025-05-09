# container-app

Deploy an [Azure container app](https://learn.microsoft.com/en-us/azure/container-apps/overview) to a [Container app environment](https://learn.microsoft.com/en-us/azure/container-apps/environment). Integrates with the [container-app-environment module](../container-app-environment/).

## Terraform documentation
For the list of inputs, outputs, resources... check the [terraform module documentation](tfdocs.md).

## Usage
Create the common container app environment:
```hcl
module "container-app-environment" {
  source = "../../../dtos-devops-templates/infrastructure/modules/container-app-environment"

  name                       = "manage-breast-screening-${var.environment}"
  resource_group_name        = azurerm_resource_group.this.name
  log_analytics_workspace_id = data.terraform_remote_state.audit.outputs.log_analytics_workspace_id
  vnet_integration_subnet_id = module.container_app_subnet.id
}
```

Create a webapp for a container listening on port 8000. The webapp will be available on internal URL `https://<name>.<container app environment default domain>`:
```hcl
module "webapp" {
  source                           = "../../../modules/dtos-devops-templates/infrastructure/modules/container-app"
  name                             = "manage-breast-screening-web-${var.environment}"
  container_app_environment_id     = module.container-app-environment.id
  resource_group_name              = azurerm_resource_group.this.name
  docker_image                    = var.docker_image
  environment_variables = {
    "ALLOWED_HOSTS" = "manage-breast-screening-web-${var.environment}.${module.container-app-environment.default_domain}"
  }
  is_web_app = true
  http_port  = 8000
}
```

Create a background worker (no ingress):
```hcl
module "worker" {
  source                           = "../../../modules/dtos-devops-templates/infrastructure/modules/container-app"
  name                             = "manage-breast-screening-worker-${var.environment}"
  container_app_environment_id     = module.container-app-environment.id
  resource_group_name              = azurerm_resource_group.this.name
  docker_image                     = var.docker_image_worker
}
```

## Key vault secrets
The container app can be mapped to an Azure key vault. All secrets are fetched and provided as secret environment variables to the app. The values are updated when terraform runs, or automatically within 30 min.

A secret name in key vault must use hyphens: `SECRET-KEY`. It is automatically mapped as an environment variable with underscore: `SECRET_KEY`.

**Warning:** The module cannot read from key vault if doesn't exist yet:
1. For each environment, create first via terraform:
    - key vault with the [key-vault module](../key-vault/)
    - container-app with `app_key_vault_id` from above and `fetch_secrets_from_app_key_vault` set to `false` (default)
1. Add the secrets to the key vault manually
1. Set `fetch_secrets_from_app_key_vault` set to `true` and run terraform to populate the app secret environment variables

Example:
```hcl
module "worker" {
  source                           = "../../../modules/dtos-devops-templates/infrastructure/modules/container-app"
  ...
  app_key_vault_id                 = module.app-key-vault.key_vault_id
  fetch_secrets_from_app_key_vault = var.fetch_secrets_from_app_key_vault
}

# Set fetch_secrets_from_app_key_vault to true in tfvars once the key vault is populated with secrets
```
