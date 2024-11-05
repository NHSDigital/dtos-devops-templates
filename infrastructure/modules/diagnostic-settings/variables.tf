variable "name" {
  type        = string
  description = "value of the name of the diagnostic setting"
}

variable "enabled_log" {
  type        = list(string)
  description = "value of the enabled log"
}

variable "eventhub_authorization_rule_id" {
  type        = string
  description = "value of the eventhub authorization rule id"
  default     = null
}

variable "eventhub_name" {
  type        = string
  description = "value of the eventhub name"
  default     = null
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "value of the log analytics workspace id"
}

variable "metric" {
  type        = list(string)
  description = "value of the metric"
}

variable "storage_account_id" {
  type        = string
  description = "value of the storage account id"
  default     = null
}

variable "target_resource_id" {
  type        = string
  description = "value of the target resource id"
}
