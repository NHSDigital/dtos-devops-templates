variable "name" {
  description = "The name of the DNS A Record service."
  type        = string
  validation {
    condition     = can(regex("^[[:alnum:]*](?:[[:alnum:]-._]{0,61}[[:alnum:]])?$", var.name))
    error_message = "The DNS A Record name must be up to 63 characters, start with an alphanumeric character or *, end with an alphanumeric character, and can contain alphanumeric characters, dots, hyphens and underscores."
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
