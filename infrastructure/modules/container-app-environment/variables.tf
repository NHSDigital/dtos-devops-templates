variable "name" {
  description = "Name of the container app environment."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group to create the container app environment in."
  type        = string
}

variable "location" {
  type        = string
  description = "The location/region where the container app environment is created."
  default     = "UK South"
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "ID of the log analytics workspace to send resource logging to via diagnostic settings"
}

variable "vnet_integration_subnet_id" {
  type        = string
  description = "ID of the subnet for the container app environment. Must be at least /23"
}

variable "private_dns_zone_rg_name" {
  type        = string
  description = "Name of the hub resource group where the private DNS zone is located. This is only required if adding custom DNS records, for instance when hosting container apps with an HTTP ingress."
  default     = null
}

variable "workload_profile" {
  type = object({
    name                  = optional(string, "Consumption")
    workload_profile_type = optional(string, "Consumption")
    minimum_count         = optional(number, 0)
    maximum_count         = optional(number, 1)
  })
  description = "Workload profile for the container app environment. This defines the scaling and resource allocation for the environment. Possible workload_profile_type values include Consumption, D4, D8, D16, D32, E4, E8, E16 and E32."
}

variable "zone_redundancy_enabled" {
  type        = bool
  description = "Enable availability zone redundancy for the container app environment. Should be set to true in production."
  default     = false
}

locals {
  dns_record = replace(
    azurerm_container_app_environment.main.default_domain,
    ".azurecontainerapps.io",
    ""
  )
}
