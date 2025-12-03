variable "name" {
  description = "Name of the container app. Limited to 32 characters"
  type        = string
}

variable "location" {
  type        = string
  description = "The location/region where the container app is created."
  default     = "UK South"
}

variable "container_app_environment_id" {
  description = "ID of the container app environment."
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
variable "acr_managed_identity_id" {
  description = "Managed identity ID for the container registry. Required if using a private registry."
  type        = string
  default     = null
}

variable "acr_login_server" {
  description = "Container registry server. Required if using a private registry."
  type        = string
  default     = null
}

variable "docker_image" {
  description = "Docker image and tag. Format: <registry>/<repository>:<tag>"
  type        = string
}

variable "environment_variables" {
  description = "Environment variables to pass to the container app. Only non-secret variables. Secrets can be stored in key vault 'app_key_vault_id'"
  type        = map(string)
  default     = {}
}

variable "secret_variables" {
  description = "Secret environment variables to pass to the container app."
  type        = map(string)
  default     = {}
}

variable "min_replicas" {
  description = "Minimum number of running containers (replicas). Replicas can scale from 0 to many depending on auto scaling rules (TBD)"
  type        = number
  default     = 1
}

variable "is_web_app" {
  description = "Is this a web app? If true, ingress is enabled."
  type        = bool
  default     = false
}

variable "is_tcp_app" {
  description = "Is this a TCP app? If true, ingress is enabled."
  type        = bool
  default     = false
}

variable "port" {
  description = "Internal port for ingress. Default is 8080."
  type        = number
  default     = 8080
}

variable "exposed_port" {
  description = "Externally exposed port for ingress. Default is var.port."
  type        = number
  default     = null
}

variable "memory" {
  description = "Memory allocated to the app (GiB). Also dictates the CPU allocation: CPU(%)=MEMORY(Gi)/2. Maximum: 4Gi"
  default     = "0.5"
  type        = number
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

variable "enable_entra_id_authentication" {
  description = "Enable authentication for the container app. If true, the app will use Entra ID authentication to restrict web access."
  type        = bool
  default     = false
}

variable "unauthenticated_action" {
  description = "Action for unauthenticated requests: RedirectToLoginPage, Return401, Return403, AllowAnonymous"
  type        = string
  default     = "RedirectToLoginPage"
  validation {
    condition     = contains(["RedirectToLoginPage", "Return401", "Return403", "AllowAnonymous"], var.unauthenticated_action)
    error_message = "Invalid unauthenticated action. Must be one of: RedirectToLoginPage, Return401, Return403, AllowAnonymous."
  }
}

# Always fetch the AAD client secret from Key Vault
variable "infra_key_vault_name" {
  description = "Name of Key Vault to retrieve the AAD client secrets"
  type        = string
  default     = null
}
variable "infra_key_vault_rg" {
  description = "Resource group of the Key Vault"
  type        = string
  default     = null
}
variable "infra_secret_names" {
  description = "List of secret names to fetch from the infra key vault. Used to fetch AAD client secrets."
  type        = list(string)
  default = [
    "aad-client-id",
    "aad-client-secret",
    "aad-client-audiences"
  ]
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

variable "alert_memory_threshold" {
  type        = number
  description = "If alerting is enabled this will control what the memory threshold will be, default will be 80."
  default     = 80
}

variable "alert_cpu_threshold" {
  type        = number
  description = "If alerting is enabled this will control what the cpu threshold will be, default will be 80."
  default     = 80
}

variable "replica_restart_alert_threshold" {
  type        = number
  description = "The replica restart alert threshold, default will be 1."
  default     = 1
}

variable "probe_path" {
  description = "Path for the HTTP health probe. If null, HTTP health probe is disabled. Note /healthcheck is the normal convention."
  type        = string
  default     = null
}

locals {
  memory = "${var.memory}Gi"
  cpu    = var.memory / 2

  alert_frequency_map = {
    PT5M  = "PT1M"
    PT15M = "PT1M"
    PT30M = "PT1M"
    PT1H  = "PT1M"
    PT6H  = "PT5M"
    PT12H = "PT5M"
  }
  alert_frequency = local.alert_frequency_map[var.alert_window_size]
  probe_enabled   = var.probe_path != null && var.is_web_app
}
