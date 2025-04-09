variable "name" {
  type        = string
  description = "value of the name of the policy assignment"
}

variable "enforce" {
  description = "Specifies if this Policy should be enforced or not. Defaults to true."
  type        = bool
  default     = true # Defaults to true if not specified
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "id of the log analytics workspace to send resource logging to via diagnostic settings if logging to log analytic workspace is being used."
  default     = null
}


variable "resource_group_id" {
  description = "The resource group ID for the resource group policy assignment."
  type        = string
}

variable "policy_definition_id" {
  description = "The ID of the policy definition to assign."
  type        = string
}

variable "subscription_id" {
  description = "The subscription ID to which the policy will be assigned."
  type        = string
}



# variable "enabled_log" {
#   type        = list(string)
#   description = "value of the enabled log"
#   default     = []
# }

# variable "eventhub_authorization_rule_id" {
#   type        = string
#   description = "value of the eventhub authorization rule id"
#   default     = null
# }

# variable "eventhub_name" {
#   type        = string
#   description = "value of the eventhub name if logging to eventhub is being used."
#   default     = null
# }

# variable "metric" {
#   type        = list(string)
#   description = "value of the metric"
#   default     = []
# }

# variable "metric_enabled" {
#   type        = bool
#   description = "to enable retention for diagnostic settings metric"
#   default     = true
# }

# variable "target_resource_id" {
#   type        = string
#   description = "value of the target resource id"
# }