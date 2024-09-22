variable "location" {
  description = "The location/region where the private endpoint will be created."
  type        = string
}

variable "name" {
  description = "The name of the private endpoint."
  type        = string
}

variable "private_dns_zone_group" {
  description = "A list of private DNS zone configurations."
  default     = []
  type = list(object({
    name                 = string
    private_dns_zone_ids = list(string)
  }))
}

variable "private_service_connection" {
  description = "A list of private service connection configurations."
  default     = []
  type = list(object({
    name                           = string
    private_connection_resource_id = string
    group_ids                      = list(string)
    request_message                = string
  }))
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
