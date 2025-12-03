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
The container app can be mapped to Azure Key Vaults for secret management:

- **App Key Vault:**
  - All secrets from the app key vault are fetched and mapped to secret environment variables if `fetch_secrets_from_app_key_vault = true` and `app_key_vault_id` is provided.
  - Secret names in Key Vault must use hyphens (e.g., `SECRET-KEY`). These are mapped to environment variables with underscores (e.g., `SECRET_KEY`).
  - Secrets are updated when Terraform runs, or automatically within 30 minutes.

- **Infra Key Vault:**
  - When authentication is enabled (`enable_entra_id_authentication = true`), secrets are fetched from the infra key vault using the list in `infra_secret_names` (default: `aad-client-id`, `aad-client-secret`, `aad-client-audiences`).
  - You can override `infra_secret_names` to fetch additional or custom secrets as needed.
  - The infra key vault must exist and be populated with the required secrets before enabling authentication.

**Warning:** The module cannot read from the app key vault if it doesn't exist yet. Recommended workflow:
1. Create the key vault(s) using the [key-vault module](../key-vault/).
2. Deploy the container app with `fetch_secrets_from_app_key_vault = false` (default).
3. Manually add the required secrets to the key vault(s).
4. Set `fetch_secrets_from_app_key_vault = true`, then re-run Terraform to populate the app with secret environment variables and enable authentication.

Example (app secrets):
```hcl
module "worker" {
  source                           = "../../../modules/dtos-devops-templates/infrastructure/modules/container-app"
  ...
  app_key_vault_id                 = module.app-key-vault.key_vault_id
  fetch_secrets_from_app_key_vault = true
}
```

Example (infra secrets for authentication):
```hcl
module "container-app" {
  ...
  enable_entra_id_authentication           = true
  infra_key_vault_name  = "my-infra-kv"
  infra_key_vault_rg    = "my-infra-rg"
  infra_secret_names    = ["aad-client-id", "aad-client-secret", "aad-client-audiences"] # can be customized
}
```

> **Note:** If your infra key vault is in a different subscription, configure the `azurerm.hub` provider in your root module and pass it to this module.

## Authentication

To enable Azure AD authentication:
- Set `enable_entra_id_authentication = true`.
- Provide the infra key vault details (`infra_key_vault_name`, `infra_key_vault_rg`).
- Ensure the infra key vault contains the required secrets listed in `infra_secret_names` (default: `aad-client-id`, `aad-client-secret`, `aad-client-audiences`).
- You may customize `infra_secret_names` to fetch additional secrets if needed.

Example:
```hcl
module "container-app" {
  ...
  enable_entra_id_authentication           = true
  infra_key_vault_name  = "my-infra-kv"
  infra_key_vault_rg    = "my-infra-rg"
  infra_secret_names    = ["aad-client-id", "aad-client-secret", "aad-client-audiences"]
}
```

## Alerts

To enable container app alerting:
- Set `enable_alerting = true`.

Example:
```hcl
module "container-app" {
  ...
  enable_alerting                 = true
  action_group_id                 = <action_group_id>
  alert_memory_threshold          = 80 (already defaults to this)
  alert_cpu_threshold             = 80 (already defaults to this)
  replica_restart_alert_threshold = 1 (already defaults to this)
}
```

## Container Probes

To enable container probs on webapps:
- Set `probe_path = "/healthcheck"` (by convention).
- Ensure the application accepts requests from `127.0.0.1` and `localhost` so the probe running inside the container can access the health endpoint.
