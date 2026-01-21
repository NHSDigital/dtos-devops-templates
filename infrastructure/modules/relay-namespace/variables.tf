variable "name" {
  description = "The name of the Azure Relay namespace."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]{4,48}[a-zA-Z0-9]$", var.name))
    error_message = "The Relay namespace name must be 6-50 characters, start with a letter, end with alphanumeric, and contain only letters, numbers, and hyphens."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Relay namespace."
  type        = string
}

variable "location" {
  description = "The location/region where the Relay namespace is created."
  type        = string
}

variable "sku_name" {
  description = "The SKU for the Relay namespace. Only 'Standard' is supported."
  type        = string
  default     = "Standard"

  validation {
    condition     = var.sku_name == "Standard"
    error_message = "Azure Relay namespace only supports 'Standard' SKU."
  }
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "ID of the Log Analytics workspace to send resource logging to via diagnostic settings."
}

variable "monitor_diagnostic_setting_relay_enabled_logs" {
  type        = list(string)
  description = "Controls what logs will be enabled for the Relay namespace."
  default     = ["HybridConnectionsEvent"]
}

variable "monitor_diagnostic_setting_relay_metrics" {
  type        = list(string)
  description = "Controls what metrics will be enabled for the Relay namespace."
  default     = ["AllMetrics"]
}

variable "private_endpoint_properties" {
  description = "Consolidated properties for the Azure Relay Private Endpoint."
  type = object({
    private_dns_zone_ids_relay           = optional(list(string), [])
    private_endpoint_enabled             = optional(bool, false)
    private_endpoint_subnet_id           = optional(string, "")
    private_endpoint_resource_group_name = optional(string, "")
    private_service_connection_is_manual = optional(bool, false)
  })

  validation {
    condition = (
      can(var.private_endpoint_properties == null) ||
      can(var.private_endpoint_properties.private_endpoint_enabled == false) ||
      can((length(var.private_endpoint_properties.private_dns_zone_ids_relay) > 0 &&
        length(var.private_endpoint_properties.private_endpoint_subnet_id) > 0
        )
      )
    )
    error_message = "Both private_dns_zone_ids_relay and private_endpoint_subnet_id must be provided if private_endpoint_enabled is true."
  }
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
