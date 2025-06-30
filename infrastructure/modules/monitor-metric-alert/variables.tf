variable "name" {
  description = "Name of the metric alert"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group where the alert will be created"
  type        = string
}

variable "subscription_id" {
  description = "Subscription ID to monitor"
  type        = string
}

variable "action_group_id" {
  description = "ID of the action group to notify"
  type        = string
}

variable "severity" {
  description = "Severity level of the alert (0 is highest, 4 is lowest)"
  type        = number
  default     = 2
}

variable "frequency" {
  description = "How often the metric alert is checked (e.g., PT1M)"
  type        = string
  default     = "PT5M"
}

variable "evaluation_frequency" {
  description = "How often to evaluate the alert rule (e.g., PT5M)"
  type        = string
  default     = "PT5M"
}

variable "window_size" {
  description = "Time window over which data is collected (e.g., PT5M)"
  type        = string
  default     = "PT15M"
}

variable "enabled" {
  description = "Whether the alert rule is enabled"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to associate with the alert"
  type        = map(string)
  default     = {}
}
