variable "subscription_name" {
  description = "The name of the Event Grid event subscription."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9_][a-zA-Z0-9-_]{0,62}[a-zA-Z0-9_]$", var.name))
    error_message = "The Event Grid Subscription name must be between 1 and 64 characters and can only contain alphanumeric characters, hyphens, and underscores."
  }
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the Event Grid. Changing this forces a new resource to be created."
}

variable "function_endpoint" {
  type        = string
  description = "The function endpoint value"
}

variable "principal_id" {
  type        = string
  description = "The principal id of the function app."
}

variable "azurerm_eventgrid_id" {
  description = "The azurerm Event Grid id to link to."
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to the Event Grid topic."
  type        = map(string)
  default     = {}
}

variable "dead_letter_storage_account_container_name" {
  description = "The name of storage account container for the Dead Letter queue."
  type        = string
}

variable "dead_letter_storage_account_id" {
  description = "The name of storage account container id for the Dead Letter queue."
  type        = string
}
