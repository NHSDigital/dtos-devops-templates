variable "location" {
  description = "The location/region where the private endpoint will be created."
  type        = string
}

variable "name" {
  description = "The name of the private endpoint."
  type        = string
}

variable "private_dns_zone_group" {
  description = "Private DNS zone configuration"
  type = object({
    name                 = string
    private_dns_zone_ids = list(string)
  })
}

variable "private_service_connection" {
  description = "Private service connection configuration."
  type = object({
    name                           = string
    private_connection_resource_id = string
    subresource_names              = list(string)
    is_manual_connection           = bool
  })
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the private endpoint."
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet within which the private endpoint will be created."
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
