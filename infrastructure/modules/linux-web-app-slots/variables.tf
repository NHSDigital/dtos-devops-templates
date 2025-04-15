variable "linux_web_app_id" {
  type        = string
  description = "The ID of the Linux Web App."
}

variable "name" {
  description = "The function app slot name."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]{0,58}[a-zA-Z0-9]$", var.name))
    error_message = "The Azure Linux Web App Slot name must be between 1 and 60 characters, start with an alphanumeric character, end with an alphanumeric character, and can contain alphanumeric characters and hyphens."
  }
}

variable "storage_account_access_key" {
  type        = string
  description = "The Storage Account Primary Access Key."
}

variable "storage_account_name" {
  type        = string
  description = "The name of the Storage Account."
}

variable "storage_name" {
  type        = string
  description = "The name of the Storage Account."
}

variable "share_name" {
  type        = string
  description = "The name which should be used for this Storage Account."
}

variable "storage_type" {
  type        = string
  description = "The Azure Storage Type. Possible values include AzureFiles and AzureBlob"
}

variable "linux_web_app_slots_enabled" {
  type        = bool
  description = "If slots are enabled or not."
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "Resource tags to be applied throughout the deployment."
  default     = {}
}
