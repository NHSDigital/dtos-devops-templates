resource "azurerm_container_app" "main" {
  name                         = var.name
  container_app_environment_id = var.container_app_environment_id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  identity {
    type = "SystemAssigned"
  }

  dynamic "secret" {
    for_each = var.app_key_vault_name != null ? data.azurerm_key_vault_secrets.app[0].secrets : []

    content {
      # KV secrets are uppercase and hyphen separated
      # app container secrets are lowercase and hyphen separated
      name = lower(secret.value.name)
      identity = "System"
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
        for_each = var.app_key_vault_name != null ? data.azurerm_key_vault_secrets.app[0].secrets : []
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

# resource "azurerm_role_assignment" "key_vault_reader" {
#   count                = var.app_key_vault_name != null ? 1 : 0

#   scope                = data.azurerm_key_vault.app[0].id
#   role_definition_name = "Key Vault Secrets User"
#   principal_id         = azurerm_container_app.main.identity[0].principal_id
# }

module "key_vault_reader_role" {
  source = "../rbac-assignment"

  scope                = data.azurerm_key_vault.app[0].id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_container_app.main.identity[0].principal_id
}
