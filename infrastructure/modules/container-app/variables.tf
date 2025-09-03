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

variable "enable_auth" {
  description = "Enable authentication for the container app. If true, the app will use Azure AD authentication."
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
}

variable "infra_key_vault_rg" {
  description = "Resource group of the Key Vault"
  type        = string
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

locals {
  memory = "${var.memory}Gi"
  cpu    = var.memory / 2
}
