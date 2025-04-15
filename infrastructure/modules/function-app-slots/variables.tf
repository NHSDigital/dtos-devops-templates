variable "function_app_id" {
  type        = string
  description = "The ID of the function App."
}

variable "storage_account_name" {
  type        = string
  description = "The storage account name."
}

variable "function_app_slot_enabled" {
  type        = bool
  description = "If slots are enabled or not."
  default     = false
}

variable "name" {
  description = "The function app slot name."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9_][a-zA-Z0-9-_]{0,58}[a-zA-Z0-9_]$", var.name))
    error_message = "The Function App Slot name must be between 1 and 60 characters and can only contain alphanumeric characters, hyphens, and underscores."
  }
}

variable "tags" {
  type        = map(string)
  description = "Resource tags to be applied throughout the deployment."
  default     = {}
}
