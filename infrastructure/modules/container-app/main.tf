module "container_app_identity" {
  source              = "../managed-identity"
  resource_group_name = var.resource_group_name
  location            = data.azurerm_resource_group.main.location
  uai_name            = "${var.name}-identity"
}

# Allow the container app to read secrets from keyvaults in the resource groups
module "key_vault_reader_role" {
  count = var.fetch_secrets_from_app_key_vault ? 1 : 0

  source = "../rbac-assignment"

  scope                = data.azurerm_resource_group.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.container_app_identity.principal_id
}

# Merge the identity created above with any passed in via a variables list:
locals {
  all_identity_ids = concat([var.acr_managed_identity_id], var.user_assigned_identity_ids, [module.container_app_identity.id])
}

resource "azurerm_container_app" "main" {
  name                         = var.name
  container_app_environment_id = var.container_app_environment_id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = local.all_identity_ids
  }

  dynamic "secret" {
    for_each = var.fetch_secrets_from_app_key_vault ? data.azurerm_key_vault_secrets.app[0].secrets : []

    content {
      # KV secrets are uppercase and hyphen separated
      # app container secrets are lowercase and hyphen separated
      name                = lower(secret.value.name)
      identity            = module.container_app_identity.id
      key_vault_secret_id = secret.value.id
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
      target_port                = var.http_port
      allow_insecure_connections = false
      traffic_weight {
        percentage      = 100
        latest_revision = true
      }
    }
  }
}
