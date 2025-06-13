variable "identity" {
  type = object({
    type         = string                 # "SystemAssigned", "UserAssigned", or "SystemAssigned, UserAssigned".
    identity_ids = optional(list(string)) # only required if using UserAssigned identity
  })
  default = null
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "id of the log analytics workspace to send resource logging to via diagnostic settings"
}

variable "metric_enabled" {
  type        = bool
  description = "Enables retention for diagnostic settings metric"
  default     = true
}

variable "monitor_diagnostic_setting_frontdoor_enabled_logs" {
  type        = list(string)
  description = "Controls which logs will be enabled for the Front Door profile"
}

variable "monitor_diagnostic_setting_frontdoor_metrics" {
  type        = list(string)
  description = "Controls which metrics will be enabled for the Front Door profile"
}

variable "name" {
  description = "Name of the Azure CDN Front Door Profile"
  type        = string
}

variable "resource_group_name" {
  type = string
}

variable "response_timeout_seconds" {
  description = "Response timeout in seconds for the CDN Front Door Profile"
  type        = number
  default     = null
}

variable "secrets" {
  description = "List of cdn_frontdoor_secret resources to create and bind to the Front Door profile. The key may be used by Custom Domain configs in each project, the value is a Key Vault Certificate versionless_id."
  type        = map(string)
  default     = {}
}

variable "sku_name" {
  description = "SKU name for the Azure CDN Front Door Profile (e.g., Standard_AzureFrontDoor or Premium_AzureFrontDoor)"
  type        = string
}

variable "tags" {
  type        = map(string)
  description = "Resource tags to be applied throughout the deployment."
  default     = {}
}
