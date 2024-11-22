variable "location" {
  type        = string
  description = "The location/region where the LAW is created."
}

variable "name" {
  type        = string
  description = "Is the LAW name."
}

variable "law_sku" {
  type        = string
  description = "The SKU for LAW."
}

variable "retention_days" {
  type        = number
  description = "Retention days for LAW."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A mapping of tags to assign to the resource."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which the Log Analytics Workspace is created. Changing this forces a new resource to be created."
}

variable "monitor_diagnostic_setting_log_analytics_workspace_enabled_logs" {
  type        = list(string)
  description = "Controls what logs will be enabled for the Long Analytics Workspace"
}

variable "monitor_diagnostic_setting_log_analytics_workspace_metrics" {
  type        = list(string)
  description = "Controls what metrics will be enabled for the Long Analytics Workspace"
}
