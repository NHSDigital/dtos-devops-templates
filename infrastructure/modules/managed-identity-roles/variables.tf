variable "environment" {
  type        = string
  description = "A code of the environment in which to create the user-assigned identity and role assignments."
}

variable "user_identity_prefix" {
  type        = string
  description = "A prefix to use when creating a user-assigned identity"
  default     = "UAMI-"
}

variable "location" {
  type        = string
  description = "The region where the user assigned identity must be created."
}

variable "resource_group_name" {
  type        = string
  description = "A name of a resource group to locate this user assigned identity."
}

variable "tags" {
  type        = map(string)
  description = "Resource tags to be applied throughout the deployment."
  default     = {}
}

variable "uai_name" {
  description = "The name of the user assigned identity."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9][-_a-zA-Z0-9]{1,126}[-_a-zA-Z0-9]$", var.uai_name))
    error_message = "The User-Assigned Managed Identity name must be between 3 and 128 characters, start with an alphanumeric character, end with an alphanumeric character or underscore, and can contain alphanumeric characters, hyphens, and underscores."
  }
}


