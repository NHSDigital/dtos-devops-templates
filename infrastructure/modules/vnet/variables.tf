variable "name" {
  type        = string
  description = "The name of the vnet."
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9.-]{0,78}[a-zA-Z0-9]$", var.name))
    error_message = "The Virtual Network name must be between 1 and 80 characters, start and end with an alphanumeric character, and can contain alphanumeric characters, hyphens, and periods."
  }
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the VNET. Changing this forces a new resource to be created."
}

variable "location" {
  type        = string
  description = "The region where the VNET should be created."
}

variable "dns_servers" {
  type        = list(string)
  description = "The DNS servers to be used by the VNET."
  default     = []
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "id of the log analytics workspace to send resource logging to via diagnostic settings"
}

variable "monitor_diagnostic_setting_vnet_enabled_logs" {
  type        = list(string)
  description = "Controls what logs will be enabled for the vnet"
}

variable "monitor_diagnostic_setting_vnet_metrics" {
  type        = list(string)
  description = "Controls what metrics will be enabled for the vnet"
}

variable "vnet_address_space" {
  type = string
}

variable "tags" {
  type        = map(string)
  description = "Resource tags to be applied throughout the deployment."
  default     = {}
}
