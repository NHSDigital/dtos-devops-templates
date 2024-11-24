variable "name" {
  type = string
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

variable "target_resource_id" {
  type = optional(string)
}

variable "ttl" {
  type = string
}

variable "zone_name" {
  type = string
}
