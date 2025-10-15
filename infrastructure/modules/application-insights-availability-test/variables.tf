variable "name" {
  type        = string
  description = "Name of the availability test"
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

variable "use_standard" {
  type        = bool
  description = "Create a Standard availability test (true) or a Classic the availability test  (false)"
  default     = false
}

variable "kind" {
  type        = string
  description = "Kind of availability test , e.g. 'ping' or 'standard'"
  default     = "ping"
}

variable "enabled" {
  type    = bool
  default = true
}

variable "frequency" {
  type        = number
  default     = 5
  description = "Frequency in minutes"
}

variable "timeout" {
  type        = number
  default     = 30
  description = "Timeout in seconds"
}

variable "geo_locations" {
  type        = list(string)
  default     = ["us-il-ch1-azr", "emea-azr-ams-azr"]
  description = "List of Azure test locations (provider-specific location strings)"
}

variable "configuration" {
  type        = string
  default     = ""
  description = "WebTest XML configuration for classic tests"
}

variable "standard_configuration" {
  type        = string
  default     = ""
  description = "Configuration for standard tests (JSON / provider-specific format)"
}
