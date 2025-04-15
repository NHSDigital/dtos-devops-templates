
variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the ACR. Changing this forces a new resource to be created."
}

variable "name" {
  description = "The Azure Container Registry name."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-_]{0,48}[a-zA-Z0-9]$", var.name))
    error_message = "The Container Registry name must be between 1 and 50 characters, start with an alphanumeric character, end with an alphanumeric character, and can only contain alphanumeric characters, hyphens, and underscores."
  }
}

variable "location" {
  type        = string
  description = "The location/region where the ACR is created."
}

variable "admin_enabled" {
  type        = string
  description = "Specifies whether the admin user is enabled."
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "id of the log analytics workspace to send resource logging to via diagnostic settings"
}

variable "monitor_diagnostic_setting_acr_enabled_logs" {
  type        = list(string)
  description = "Controls what logs will be enabled for the acr"
}

variable "monitor_diagnostic_setting_acr_metrics" {
  type        = list(string)
  description = "Controls what metrics will be enabled for the acr"
}

variable "private_endpoint_properties" {
  description = "Consolidated properties for the Function App Private Endpoint."
  type = object({
    private_dns_zone_ids                 = optional(list(string), [])
    private_endpoint_enabled             = optional(bool, false)
    private_endpoint_subnet_id           = optional(string, "")
    private_endpoint_resource_group_name = optional(string, "")
    private_service_connection_is_manual = optional(bool, false)
  })

  validation {
    condition = (
      can(var.private_endpoint_properties == null) ||
      can(var.private_endpoint_properties.private_endpoint_enabled == false) ||
      can((length(var.private_endpoint_properties.private_dns_zone_ids) > 0 &&
        length(var.private_endpoint_properties.private_endpoint_subnet_id) > 0
        )
      )
    )
    error_message = "Both private_dns_zone_ids and private_endpoint_subnet_id must be provided if private_endpoint_enabled is true."
  }
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Controls whether the acr may be accessed from public networks."
  default     = false
}

variable "sku" {
  type        = string
  description = "The SKU of the ACR."
}

variable "uai_name" {
  type        = string
  description = "Name of the User Assigned Identity for ACR Push"
}

variable "tags" {
  type        = map(string)
  description = "Resource tags to be applied throughout the deployment."
  default     = {}
}

variable "zone_redundancy_enabled" {
  type    = bool
  default = false
}
