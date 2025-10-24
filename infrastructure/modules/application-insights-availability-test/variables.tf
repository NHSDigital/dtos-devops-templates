variable "name" {
  type        = string
  description = "Name of the availability test, must be unique for the used application insights instance"
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the availability test."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{1,255}$", var.resource_group_name))
    error_message = "The resource group name must be between 1 and 255 characters and can only contain alphanumeric characters, hyphens, and underscores."
  }
}

variable "location" {
  type        = string
  description = "The location/region where the availability test is deployed (must match App Insights location)"
  default     = "UK South"
}

variable "application_insights_id" {
  type        = string
  description = "The Application Insights resource id to associate the availability test with"
}

variable "action_group_id" {
  type        = string
  description = "ID of the action group to notify."
}

variable "frequency" {
  type    = number
  default = 300
  validation {
    condition     = contains([300, 600, 900], var.frequency)
    error_message = "The frequency must be one of: 300, 600 or 900"
  }
  description = "Frequency of test in seconds, defaults to 300."
}

variable "timeout" {
  type        = number
  default     = 30
  description = "Timeout in seconds, defaults to 30."
}

variable "geo_locations" {
  type        = list(string)
  default     = ["emea-ru-msa-edge", "emea-se-sto-edge", "emea-gb-db3-azr"]
  description = "List of Azure test locations (provider-specific location strings for UK and Ireland)"
}

variable "target_url" {
  type        = string
  description = "The target URL for the restful endpoint to hit to validate the application is available"
}
