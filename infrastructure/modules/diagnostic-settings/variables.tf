variable "name" {
  type        = string
  description = "value of the name of the diagnostic setting"
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
  description = "value of the eventhub name if logging to eventhub is being used."
  default     = null
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "id of the log analytics workspace to send resource logging to via diagnostic settings if logging to log analytic workspace is being used."
  default     = null
}

variable "metric" {
  type        = list(string)
  description = "value of the metric"
  default     = []
}

# variable "metric_enabled" {
#   type        = bool
#   description = "to enable retention for diagnostic settings metric"
#   default     = true
# }

# variable "metric_retention_policy_days" {
#   type        = number
#   description = "value of the retention days for diagnostic settings metric set to 30 days by default"
#   default     = 30
# }

# variable "metric_retention_policy_enabled" {
#   type        = bool
#   description = "to enable retention for diagnostic settings metric"
#   default     = true
# }

variable "storage_account_id" {
  type        = string
  description = "value of the storage account id if logging to storage account is being used."
  default     = null
}

variable "target_resource_id" {
  type        = string
  description = "value of the target resource id"
}
