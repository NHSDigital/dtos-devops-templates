variable "name" {
  description = "value of the name of the diagnostic setting"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-_]{0,78}[a-zA-Z0-9]$", var.name))
    error_message = "The Diagnostic Setting name must be between 1 and 80 characters, start with an alphanumeric character, end with an alphanumeric character, and can only contain alphanumeric characters, hyphens, and underscores."
  }
}

variable "enabled_log" {
  type        = list(string)
  description = "value of the enabled log"
  default     = []
}

variable "eventhub_authorization_rule_id" {
  type        = string
  description = "value of the eventhub authorization rule id"
  default     = null
}

variable "eventhub_name" {
  type        = string
  description = "value of the EventHub name if logging to an EventHub."
  default     = null
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Identifier of a log analytics workspace to send resource logging to via diagnostic settings if logging to log analytic workspace is being used."
  default     = null
}

variable "metric" {
  type        = list(string)
  description = "value of the metric"
  default     = []
}

variable "metric_enabled" {
  type        = bool
  description = "True to retain diagnostic setting metrics, false otherwise"
  default     = true
}

variable "storage_account_id" {
  type        = string
  description = "value of the storage account id if logging to storage account is being used."
  default     = null
}

variable "target_resource_id" {
  type        = string
  description = "value of the target resource id"
}
