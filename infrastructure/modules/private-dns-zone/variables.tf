variable "name" {
  description = "The name (in FQDN form) of the zone."
  type        = string
  validation {
    condition     = can(regex("^([a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\\.)+[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?$", var.name))
    error_message = "The Private DNS Zone name must be up to 253 characters, with each label starting and ending with an alphanumeric character, and can contain alphanumeric characters, hyphens, and periods (but not underscores at the start or end of labels)."
  }
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
