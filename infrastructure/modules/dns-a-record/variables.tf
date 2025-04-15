variable "name" {
  description = "The name of the DNS A Record service."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-_]{0,253}[a-zA-Z0-9]$", var.name))
    error_message = "The DNS A Record service name must be between 1 and 255 characters and can only contain alphanumeric characters, hyphens, and underscores."
  }
}

variable "records" {
  type    = list(string)
  default = null
}

variable "resource_group_name" {
  type = string
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}

variable "target_resource_id" {
  type    = string
  default = null
}

variable "ttl" {
  type = string
}

variable "zone_name" {
  type = string
}
