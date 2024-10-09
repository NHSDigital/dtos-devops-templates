variable "name" {
  description = "The name of the private endpoint."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the private endpoint."
  type        = string
}

variable "private_dns_a_record" {
  type = object({
    zone_name    = string
    a_record_ttl = string
    ip_address   = list(string)
  })
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
