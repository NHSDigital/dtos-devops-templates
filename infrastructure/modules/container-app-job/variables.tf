variable "name" {
  description = "Name of the container app. Limited to 32 characters"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group to create the container app in."
  type        = string
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

variable "docker_image" {
  description = "Docker image and tag. Format: <registry>/<repository>:<tag>"
  type        = string
}

variable "environment_variables" {
  description = "Environment variables to pass to the container app. Only non-secret variables. Secrets must be stored in key vault 'app_key_vault_id'"
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

locals {
  memory = "${var.memory}Gi"
  cpu    = var.memory / 2
}
