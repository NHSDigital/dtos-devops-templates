variable "name" {
  description = "Name of the container app. Limited to 32 characters"
  type        = string
}

variable "container_app_environment_id" {
  description = "ID of the container app environment."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group to create the container app in."
  type        = string
}

variable "app_key_vault_name" {
  description = "Name of the key vault to store app secret. Each secret is mapped to an environment variable."
  type        = string
  default     = null
}

variable "docker_image" {
  description = "Docker image and tag. Format: <registry>/<repository>:<tag>"
  type        = string
}

variable "environment_variables" {
  description = "Environment variables to pass to the container app. Only non-secret variables. Secrets must be stored in key vault 'app_key_vault_name'"
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

variable "http_port" {
  description = "HTTP port for the web app. Default is 8080."
  type        = number
  default     = 8080
}

variable "memory" {
  description = "Memory allocated to the app (GiB). Also dictates the CPU allocation: CPU(%)=MEMORY(Gi)/2. Maximum: 4Gi"
  default     = "0.5"
  type        = number
}

locals {
  memory = "${var.memory}Gi"
  cpu    = var.memory / 2
}
