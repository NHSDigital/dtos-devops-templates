variable "assignable_scopes" {
  type = list(string)
  description = "A collection of one or more scopes at which this definition can be assigned."
  validation {
    condition = length(var.assignable_scopes) >= 1
    error_message = "At least one scope ID must be provided"
  }
}

variable "description"{
  type = string
  description = "A friendly textual description of this role and its intended purpose."
  default = "Custom role for managing access to Azure resources in the specified environment."
}

variable "environment" {
  description = "The environment name (e.g., dev, prod)"
  type        = string
}

variable "name"{
  type = string
  description = "A user-defined name for this custom role definition"
}

variable "permissions" {
  description = <<EOT
    A set of permissions to apply to the role definition. Please refer to the relevant Microsoft
    documentation related to the available "actions", "data actions", and any "not actions" available.
    Example:
      {
        actions           = ["Microsoft.Storage/storageAccounts/listkeys/action"]
        data_actions      = ["Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read"]
        not_actions       = []
        not_data_actions  = []
      }
    EOT
  type = object({
    actions          = optional(list(string), [])
    data_actions     = optional(list(string), [])
    not_actions      = optional(list(string), [])
    not_data_actions = optional(list(string), [])
  })
}

variable "scope"{
  type = string
  description = "The resource group or subscription ID that acts as the main scope at which this custom role definition will apply."
}


