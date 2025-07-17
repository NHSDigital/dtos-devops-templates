variable "assignable_scopes" {
  type = list(string)
  description = "A collection of one or more scopes at which this definition can be assigned."
  validation {
    condition = length(var.assignable_scopes) >= 1
    error_message = "At least one scope ID must be provided"
  }
}

variable "role_name" {
  type = string
  description = "A name to apply to the single global role definition"
}

variable "environment" {
  type        = string
  description = "A code of the environment in which to create the user-assigned identity and role assignments."
}

variable "location" {
  type        = string
  description = "The region where the user assigned identity must be created."
}

variable "role_scope_id" {
  type = string
  description = "The ID of a resource group or subscription for this custom role definition"
}

variable "tags" {
  type        = map(string)
  description = "Resource tags to be applied throughout the deployment."
  default     = {}
}


