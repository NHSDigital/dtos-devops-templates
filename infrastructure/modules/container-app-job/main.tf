# Merge the identities passed in via a variables:
locals {
  all_identity_ids = concat([var.acr_managed_identity_id], var.user_assigned_identity_ids)
}

resource "azurerm_container_app_job" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  container_app_environment_id = var.container_app_environment_id
  replica_timeout_in_seconds   = var.replica_timeout_in_seconds
  replica_retry_limit          = var.replica_retry_limit

  identity {
    type         = "UserAssigned"
    identity_ids = local.all_identity_ids
  }

  # Configure manual trigger for on-demand execution via CLI
  manual_trigger_config {
    parallelism              = var.job_parallelism
    replica_completion_count = var.replica_completion_count
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
