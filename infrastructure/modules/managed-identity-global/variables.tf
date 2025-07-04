variable "enable_global_rbac" {
  description = "True to enable RBAC assignments for the global User Assigned Managed Identity, False otherwise"
  type        = bool
  default     = false
}

variable "environment" {
  type        = string
  description = "A code of the environment in which to create the user-assigned identity and role assignments."
}

variable "identity_prefix" {
  type        = string
  description = "A prefix to use when creating a user-assigned identity"
  default     = "uami-global"
}

variable "principal_id" {
  description = "The principal ID (e.g., user, group, or service principal) to which the role will be assigned."
  type        = string
  default     = null
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

variable "custom_resource_roles"{
  description = "Custom roles to be assigned to specified resource types."
  type    = map(list(string))
  default = {}
}

variable "resource_ids" {
  description = "List of resource IDs to assign the UAMI onto"
  type        = list(string)
}

variable "uai_name" {
  description = "The name of the user assigned identity."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-_]{1,126}[a-zA-Z0-9_]$", var.uai_name))
    error_message = "The User-Assigned Managed Identity name must be between 3 and 128 characters, start with an alphanumeric character, end with an alphanumeric character or underscore, and can contain alphanumeric characters, hyphens, and underscores."
  }
}


