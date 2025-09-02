# Merge the identities passed in via a variables:
locals {
  all_identity_ids = compact(concat(
    [var.acr_managed_identity_id],
    var.user_assigned_identity_ids)
  )
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

  # Configure manual trigger for on-demand execution via CLI
  dynamic "manual_trigger_config" {
    for_each = var.cron_expression == null && var.scale_rule_type == null ? [1] : []
    content {
      parallelism              = var.job_parallelism
      replica_completion_count = var.replica_completion_count
    }
  }

  # Configure event trigger for event source execution
  dynamic "event_trigger_config" {
    for_each = var.cron_expression == null && var.scale_rule_type != null ? [1] : []
    content {
      parallelism              = var.job_parallelism
      replica_completion_count = var.replica_completion_count
      scale {
        max_executions              = 1
        min_executions              = 0
        polling_interval_in_seconds = var.polling_interval_in_seconds
        rules {
          name             = local.scale_rule_name
          custom_rule_type = var.scale_rule_type
          metadata         = var.scale_rule_metadata
        }
      }
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
