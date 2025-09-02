# Merge the identities passed in via a variables:
locals {
  all_identity_ids = compact(concat(
    [var.acr_managed_identity_id],
    var.user_assigned_identity_ids,
    [module.container_app_identity.id]
  ))
}

module "container_app_identity" {
  source              = "../managed-identity"
  resource_group_name = var.resource_group_name
  location            = var.location
  uai_name            = "mi-${var.name}"
}

module "key_vault_reader_role_app" {
  count = var.fetch_secrets_from_app_key_vault ? 1 : 0

  source = "../rbac-assignment"

  scope                = var.app_key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.container_app_identity.principal_id
}

resource "azurerm_container_app_job" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  container_app_environment_id = var.container_app_environment_id
  replica_timeout_in_seconds   = var.replica_timeout_in_seconds
  replica_retry_limit          = var.replica_retry_limit
  workload_profile_name        = var.workload_profile_name

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

  # Configure manual trigger for on-demand execution via CLI
  dynamic "manual_trigger_config" {
    for_each = var.cron_expression == null ? [1] : []
    content {
      parallelism              = var.job_parallelism
      replica_completion_count = var.replica_completion_count
    }
  }

  # Configure schedule trigger for scheduled execution
  dynamic "schedule_trigger_config" {
    for_each = var.cron_expression != null ? [1] : []
    content {
      cron_expression          = var.cron_expression
      parallelism              = var.job_parallelism
      replica_completion_count = var.replica_completion_count
    }
  }

  dynamic "secret" {
    for_each = var.secret_variables
    content {
      name  = replace(lower(secret.key), "_", "-")
      value = secret.value
    }
  }

  # Define the container template for the job.
  template {

    container {
      name   = var.name
      image  = var.docker_image
      cpu    = local.cpu
      memory = local.memory

      # Optional: Command to execute in the container.
      command = var.container_command
      args    = var.container_args

      # Optional: Environment variables for the container.
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

      dynamic "env" {
        for_each = var.secret_variables
        content {
          # Env vars are uppercase and underscore separated
          name = upper(replace(env.key, "-", "_"))
          # app container secrets are lowercase and hyphen separated
          secret_name = replace(lower(env.key), "_", "-")
        }
      }
    }
  }

  # Optional: Configure private registry access using Managed Identity
  dynamic "registry" {
    for_each = var.acr_login_server != null && var.acr_managed_identity_id != null ? [1] : []

    content {
      server   = var.acr_login_server
      identity = var.acr_managed_identity_id
    }
  }
}
