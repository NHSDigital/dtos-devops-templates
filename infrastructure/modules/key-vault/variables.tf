variable "enable_rbac_authorization" {
  type    = bool
  default = false
}

variable "location" {
  type        = string
  description = "The location/region where the  Key Vault is created."
}

variable "disk_encryption" {
  type        = bool
  description = "Should the disk encryption be enabled"
  default     = true
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "id of the log analytics workspace to send resource logging to via diagnostic settings"
}

variable "metric_enabled" {
  type        = bool
  description = "to enable retention for diagnostic settings metric"
  default     = true
}

variable "monitor_diagnostic_setting_keyvault_enabled_logs" {
  type        = list(string)
  description = "Controls what logs will be enabled for the keyvault"
}

variable "monitor_diagnostic_setting_keyvault_metrics" {
  type        = list(string)
  description = "Controls what metrics will be enabled for the keyvault"
}

variable "name" {
  type = string
}

variable "private_endpoint_properties" {
  description = "Consolidated properties for the Key Vault Private Endpoint."
  type = object({
    private_dns_zone_ids_keyvault        = optional(list(string), [])
    private_endpoint_enabled             = optional(bool, false)
    private_endpoint_subnet_id           = optional(string, "")
    private_endpoint_resource_group_name = optional(string, "")
    private_service_connection_is_manual = optional(bool, false)
  })

  validation {
    condition = (
      can(var.private_endpoint_properties == null) ||
      can(var.private_endpoint_properties.private_endpoint_enabled == false) ||
      can((length(var.private_endpoint_properties.private_dns_zone_ids_keyvault) > 0 &&
        length(var.private_endpoint_properties.private_endpoint_subnet_id) > 0
        )
      )
    )
    error_message = "Both private_dns_zone_ids and private_endpoint_subnet_id must be provided if private_endpoint_enabled is true."
  }
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Controls whether data in the account may be accessed from public networks."
  default     = false
}

variable "purge_protection_enabled" {
  type        = bool
  description = "Should the purge protection be enabled."
  default     = false
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the Key Vault. Changing this forces a new resource to be created."
}

variable "rbac_roles" {
  description = "List of RBAC roles to assign to the Key Vault."
  type        = list(string)
  default     = []
}

variable "soft_delete_retention" {
  type        = number
  description = "Number of days to retain a deleted vault"
  default     = "7"
}

variable "sku_name" {
  type        = string
  description = "Type of the Key Vault's SKU."
  default     = "standard"
}

variable "tags" {
  type        = map(string)
  description = "Resource tags to be applied throughout the deployment."
  default     = {}
}
