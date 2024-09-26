variable "name" {
  type        = string
  description = "The name (in FQDN form) of the zone."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the zone. Changing this forces a new resource to be created."
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
