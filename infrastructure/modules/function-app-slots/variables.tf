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
  type        = string
  description = "The function app slot name."
}

variable "tags" {
  type        = map(string)
  description = "Resource tags to be applied throughout the deployment."
  default     = {}
}
