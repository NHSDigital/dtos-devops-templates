module "container_app_identity" {
  source              = "../managed-identity"
  resource_group_name = var.resource_group_name
  location            = var.location
  uai_name            = "mi-${var.name}"
}

# Allow the container app to read secrets from keyvaults in the resource groups
module "key_vault_reader_role_app" {
  count = var.fetch_secrets_from_app_key_vault ? 1 : 0

  source = "../rbac-assignment"

  scope                = var.app_key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.container_app_identity.principal_id
}

module "key_vault_reader_role_infra" {
  count = var.enable_entra_id_authentication ? 1 : 0

  source = "../rbac-assignment"

  scope                = data.azurerm_key_vault.infra[0].id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.container_app_identity.principal_id
}

# Merge the identity created above with any passed in via a variables list:
locals {
  all_identity_ids = compact(concat(
    [var.acr_managed_identity_id],
    var.user_assigned_identity_ids,
    [module.container_app_identity.id]
  ))
}

resource "azurerm_container_app" "main" {
  name                         = var.name
  container_app_environment_id = var.container_app_environment_id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"
  workload_profile_name        = var.workload_profile_name

  identity {
    type         = "UserAssigned"
    identity_ids = local.all_identity_ids
  }

  dynamic "secret" {

    for_each = concat(var.fetch_secrets_from_app_key_vault ? data.azurerm_key_vault_secrets.app[0].secrets : [],
    var.enable_entra_id_authentication ? [for s in data.azurerm_key_vault_secret.infra : { name = s.name, id = s.id }] : [])

    content {
      # KV secrets are uppercase and hyphen separated
      # app container secrets are lowercase and hyphen separated
      name                = lower(secret.value.name)
      identity            = module.container_app_identity.id
      key_vault_secret_id = secret.value.id
    }
  }

  dynamic "secret" {
    for_each = var.secret_variables
    content {
      name  = replace(lower(secret.key), "_", "-")
      value = secret.value
    }
  }

  template {
    container {
      name   = var.name
      image  = var.docker_image
      cpu    = local.cpu
      memory = local.memory

      dynamic "env" {
        for_each = var.environment_variables
        content {
          name  = env.key
          value = env.value
        }
      }

      dynamic "env" {
        for_each = var.secret_variables
        content {
          # Env vars are uppercase and underscore separated
          name        = upper(replace(env.key, "-", "_"))
          secret_name = replace(lower(env.key), "_", "-")
        }
      }

      dynamic "env" {
        for_each = var.fetch_secrets_from_app_key_vault ? data.azurerm_key_vault_secrets.app[0].secrets : []
        content {
          # Env vars are uppercase and underscore separated
          name = upper(replace(env.value.name, "-", "_"))
          # KV secrets are uppercase and hyphen separated
          # app container secrets are lowercase and hyphen separated
          secret_name = lower(env.value.name)
        }
      }
    }
    min_replicas = var.min_replicas
  }

  dynamic "registry" {
    for_each = var.acr_login_server != null ? [1] : []

    content {
      server   = var.acr_login_server
      identity = var.acr_managed_identity_id
    }
  }

  dynamic "ingress" {
    for_each = var.is_web_app ? [1] : []

    content {
      external_enabled           = true
      target_port                = var.port
      allow_insecure_connections = false
      traffic_weight {
        percentage      = 100
        latest_revision = true
      }
    }
  }

  dynamic "ingress" {
    for_each = var.is_tcp_app ? [1] : []

    content {
      external_enabled           = true
      target_port                = var.port
      exposed_port               = var.exposed_port != null ? var.exposed_port : var.port
      allow_insecure_connections = false
      transport                  = "tcp"
      traffic_weight {
        percentage      = 100
        latest_revision = true
      }
    }
  }
}

# Enable Microsoft Entra ID authentication if specified
# Requires infra key vault to contain secrets:
## - aad-client-id
## - aad-client-secret
## - aad-client-audiences
resource "azapi_resource" "auth" {
  count     = var.enable_entra_id_authentication ? 1 : 0
  type      = "Microsoft.App/containerApps/authConfigs@2025-01-01"
  name      = "current"
  parent_id = azurerm_container_app.main.id

  body = {
    properties = {
      platform = {
        enabled = true
      }
      globalValidation = {
        unauthenticatedClientAction = var.unauthenticated_action
      }
      identityProviders = {
        azureActiveDirectory = {
          enabled = true
          registration = {
            clientId                = data.azurerm_key_vault_secret.infra["aad-client-id"].value
            clientSecretSettingName = "aad-client-secret"
            openIdIssuer            = "https://sts.windows.net/${data.azurerm_client_config.current.tenant_id}/v2.0"
          }
          validation = {
            # Values within the Key Vault secret are separated by commas
            allowedAudiences = split(",", data.azurerm_key_vault_secret.infra["aad-client-audiences"].value)
          }
        }
      }
      httpSettings = {
        forwardProxy = {
          convention           = "Custom"
          customHostHeaderName = "X-forwarded-Host"
        }
      }
    }
  }
  depends_on = [data.azurerm_key_vault_secret.infra]
}
