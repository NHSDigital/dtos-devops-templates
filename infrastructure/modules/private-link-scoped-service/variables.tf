variable "name" {
  type        = string
  description = "The name of the Azure Monitor Private Link Scoped Service."
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9.-]{0,62}[a-zA-Z0-9]$", var.name))
    error_message = "The Azure Monitor Private Link Scoped Service name must be between 1 and 64 characters, start and end with an alphanumeric character, and can contain alphanumeric characters, hyphens, and periods."
  }
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the zone. Changing this forces a new resource to be created."
}

variable "linked_resource_id" {
  type        = string
  description = "The ID of the resource to link to the private link service."
}

variable "scope_name" {
  type        = string
  description = "The name of the private link scope."
}
