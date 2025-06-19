variable "name" {
  description = "The name of the Private DNS A Record."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?$", var.name))
    error_message = "The Private DNS A Record name must be up to 63 characters, start and end with an alphanumeric character, and can contain alphanumeric characters and hyphens."
  }
}

variable "records" {
  type = list(string)
}

variable "resource_group_name" {
  type = string
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}

variable "ttl" {
  type = string
}

variable "zone_name" {
  type = string
}
