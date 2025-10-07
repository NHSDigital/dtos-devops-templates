variable "name" {
  description = "Name of the container app. Limited to 32 characters"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group to create the container app in."
  type        = string
}

variable "app_key_vault_id" {
  description = "ID of the key vault to store app secrets. Each secret is mapped to an environment variable. Required when fetch_secrets_from_app_key_vault is true."
  type        = string
  default     = null
}
variable "fetch_secrets_from_app_key_vault" {
  description = <<EOT
    Fetch secrets from the app key vault and map them to secret environment variables. Requires app_key_vault_id.

    WARNING: The key vault must be created by terraform and populated manually before setting this to true.
    EOT
  type        = bool
  default     = false
  nullable    = false
}

variable "location" {
  type        = string
  description = "The location/region where the container app environment is created."
  default     = "UK South"
}

variable "acr_login_server" {
  description = "Container registry server. Required if using a private registry."
  type        = string
  default     = null
}

variable "acr_managed_identity_id" {
  description = "Managed identity ID for the container registry. Required if using a private registry."
  type        = string
  default     = null
}

variable "container_app_environment_id" {
  description = "ID of the container app environment."
  type        = string
}

variable "container_args" {
  description = "The arguments to pass to the container command. Optional."
  type        = list(string)
  default     = null
}

variable "container_command" {
  description = "The commands to execute in the container. Optional."
  type        = list(string)
  default     = null
}

variable "cron_expression" {
  description = "Cron formatted repeating schedule of a Cron Job eg. '0 5 * * *'. Optional."
  type        = string
  default     = null
}

variable "docker_image" {
  description = "Docker image and tag. Format: <registry>/<repository>:<tag>"
  type        = string
}

variable "environment_variables" {
  description = "Environment variables to pass to the container app. Only non-secret variables. Secrets must be stored in key vault 'app_key_vault_id'"
  type        = map(string)
  default     = {}
}

variable "secret_variables" {
  description = "Secret environment variables to pass to the container app."
  type        = map(string)
  default     = {}
}

variable "job_parallelism" {
  description = "The number of replicas that can run in parallel."
  type        = number
  default     = 1
}

variable "memory" {
  description = "Memory allocated to the app (GiB). Also dictates the CPU allocation: CPU(%)=MEMORY(Gi)/2. Maximum: 4Gi"
  type        = number
  default     = "0.5"
}

variable "replica_completion_count" {
  description = "The number of replicas that must complete successfully for the job to be considered successful."
  type        = number
  default     = 1
}

variable "replica_timeout_in_seconds" {
  description = "The timeout in seconds for a replica to complete execution."
  type        = number
  default     = 300
}

variable "replica_retry_limit" {
  description = "The number of retries allowed for a replica in case of failure."
  type        = number
  default     = 3
}

variable "user_assigned_identity_ids" {
  description = "List of user assigned identity IDs to assign to the container app."
  type        = list(string)
  default     = []
}

variable "workload_profile_name" {
  description = "Workload profile in this container app environment"
  type        = string
  default     = "Consumption"
  nullable    = false
}

variable "enable_alerting" {
  description = "Whether monitoring and alerting is enabled for the PostgreSQL Flexible Server."
  type        = bool
  default     = false
}

variable "action_group_id" {
  type        = string
  description = "ID of the action group to notify."
  default     = null
}

variable "alert_window_size" {
  type     = string
  nullable = false
  default  = "PT5M"
  validation {
    condition     = contains(["PT1M", "PT5M", "PT15M", "PT30M", "PT1H", "PT6H", "PT12H"], var.alert_window_size)
    error_message = "The alert_window_size must be one of: PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H"
  }
  description = "The period of time that is used to monitor alert activity e.g. PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H. The interval between checks is adjusted accordingly."
}

variable "log_analytics_workspace_id" {
  description = "Log analytics workspace ID"
  type        = string
}

variable "alert_frequency" {
  type        = number
  description = "Frequency (in minutes) at which rule condition should be evaluated. Values must be between 5 and 1440 (inclusive). Default is 15"
  default     = 15
}

variable "time_window" {
  type        = number
  description = "Time window for which data needs to be fetched for query (must be greater than or equal to frequency). Values must be between 5 and 2880 (inclusive).  Default is 30"
  default     = 30
}

locals {
  memory = "${var.memory}Gi"
  cpu    = var.memory / 2
}
