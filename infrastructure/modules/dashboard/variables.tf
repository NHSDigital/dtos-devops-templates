variable "location" {
  type        = string
  description = "The location/region where the dashboard is created."
}

variable "name" {
  description = "Is the dashboard workspace name."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-_]{0,253}[a-zA-Z0-9]$", var.name))
    error_message = "The Dashboard name must be between 1 and 255 characters, start and end with an alphanumeric character, and can contain alphanumeric characters, hyphens, periods, and underscores (but not at the start or end)."
  }
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which the Dashboard is created. Changing this forces a new resource to be created."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A mapping of tags to assign to the resource."
}

variable "dashboard_properties" {
  type        = string
  default     = "{}"
  description = "JSON data representing dashboard body. See above for details on how to obtain this from the Portal."
}
