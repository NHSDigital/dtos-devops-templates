variable "name" {
  description = "The name (in FQDN form) of the zone."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9.-]{0,62}[a-zA-Z0-9]$", var.name))
    error_message = "The Private DNS Resolver name must be between 1 and 64 characters, start and end with an alphanumeric character, and can contain alphanumeric characters, hyphens, and periods."
  }
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the zone. Changing this forces a new resource to be created."
}

variable "location" {
  type        = string
  description = "The region where the resolver is created."
}

variable "inbound_endpoint_config" {
  description = "The configuration for the inbound endpoint."
  type = object({
    name                         = string
    private_ip_allocation_method = string
    subnet_id                    = string
  })
  default = {
    name                         = ""
    private_ip_allocation_method = ""
    subnet_id                    = ""
  }
}

variable "outbound_endpoint_config" {
  description = "The configuration for the outbound endpoint."
  type = object({
    name      = string
    subnet_id = string
  })
  default = {
    name      = ""
    subnet_id = ""
  }
}

variable "vnet_id" {
  type        = string
  description = "The ID of the virtual network to which the zone will be linked."
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
