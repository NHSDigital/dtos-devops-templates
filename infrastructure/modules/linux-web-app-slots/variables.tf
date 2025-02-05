variable "linux_web_app_id" {
  type        = string
  description = "The ID of the Linux Web App."
}

variable "name" {
  type        = string
  description = "The function app slot name."
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
