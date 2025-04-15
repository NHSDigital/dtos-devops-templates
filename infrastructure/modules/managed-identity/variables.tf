variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the Identity. Changing this forces a new resource to be created."
}

variable "location" {
  type        = string
  description = ""
}

variable "uai_name" {
  description = "The name of the user assigned identity."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-_]{1,126}[a-zA-Z0-9_]$", var.uai_name))
    error_message = "The User-Assigned Managed Identity name must be between 3 and 128 characters, start with an alphanumeric character, end with an alphanumeric character or underscore, and can contain alphanumeric characters, hyphens, and underscores."
  }
}

variable "tags" {
  type        = map(string)
  description = "Resource tags to be applied throughout the deployment."
  default     = {}
}
