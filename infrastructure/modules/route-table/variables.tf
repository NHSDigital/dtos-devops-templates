variable "name" {
  description = "The name of the route table."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-_]{0,78}[a-zA-Z0-9]$", var.name))
    error_message = "The Route Table name must be between 1 and 80 characters, start with an alphanumeric character, end with an alphanumeric character, and can only contain alphanumeric characters, hyphens, and underscores."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the route table."
  type        = string
}

variable "location" {
  description = "The location/region where the route table is created."
  type        = string
}

variable "bgp_route_propagation_enabled" {
  description = "Should BGP route propagation be enabled on this route table?"
  type        = bool
}

variable "routes" {
  description = "A list of routes to add to the route table."
  type = list(object({
    name                   = string
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = optional(string)
  }))

  validation {
    condition = alltrue([
      for route in var.routes : (
        route.name != "" &&
        route.address_prefix != "" &&
        contains(["VirtualAppliance", "VnetLocal", "Internet", "VirtualNetworkGateway", "None"], route.next_hop_type) && (route.next_hop_type != "VirtualAppliance" || route.next_hop_in_ip_address != "")
      )
    ])
    error_message = "Each route must have a valid name, address_prefix, and next_hop_type. If next_hop_type is VirtualAppliance, next_hop_in_ip_address must also be specified."
  }
}

variable "subnet_ids" {
  description = "A list of subnet IDs to associate with the route table."
  type        = list(string)
}

variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
