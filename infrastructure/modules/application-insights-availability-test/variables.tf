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

variable "http_verb" {
  description = "HTTP verb (GET, POST, PUT, PATCH, DELETE, HEAD, OPTIONS)"
  type        = string
  default     = "GET"
  validation {
    condition     = contains(["GET", "POST", "PUT", "PATCH", "DELETE", "HEAD", "OPTIONS"], var.http_verb)
    error_message = "http_verb must be one of GET, POST, PUT, PATCH, DELETE, HEAD, OPTIONS."
  }
}

variable "headers" {
  description = "Map of request headers to send (name => value)"
  type        = map(string)
  default     = {}
}

variable "ssl_validation" {
  description = "SSL validation configuration for the availability test."
  type = object({
    expected_status_code        = optional(number, null)
    ssl_cert_remaining_lifetime = optional(number, null)
  })

  validation {
    condition = (
      var.ssl_validation == null ||
      try(var.ssl_validation.expected_status_code, 0) == 0 ||
      (try(var.ssl_validation.expected_status_code, 0) >= 100 &&
      try(var.ssl_validation.expected_status_code, 0) < 600)
    )
    error_message = "The expected status code must be 0 ('0' means 'response code < 400') or a valid HTTP status code between 100 and 599."
  }

  validation {
    condition = (
      var.ssl_validation == null ||
      try(var.ssl_validation.ssl_cert_remaining_lifetime, null) == null ||
      (try(var.ssl_validation.ssl_cert_remaining_lifetime, 0) >= 1 &&
      try(var.ssl_validation.ssl_cert_remaining_lifetime, 0) <= 365)
    )
    error_message = "The SSL certificate remaining lifetime must be null or an integer between 1 and 365."
  }

  default  = null
  nullable = true
}

variable "alert" {
  type = object({
    description   = optional(string, "Availability test alert")
    frequency     = optional(string, "PT1M")
    window_size   = optional(string, "PT5M")
    auto_mitigate = optional(bool, true)
  })

  validation {
    condition = contains(
      ["PT1M", "PT5M", "PT15M", "PT30M", "PT1H"],
      var.alert.frequency
    )
    error_message = "Frequency must be one of: PT1M, PT5M, PT15M, PT30M, PT1H"
  }

  validation {
    condition = contains(
      ["PT1M", "PT5M", "PT15M", "PT30M", "PT1H", "PT6H", "PT12H", "P1D"],
      var.alert.window_size
    )
    error_message = "Window size must be one of: PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H, P1D"
  }

  default = {}
}
