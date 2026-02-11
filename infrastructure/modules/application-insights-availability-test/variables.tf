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
  validation {
    condition     = var.timeout > 0
    error_message = "Timeout must be a positive number of seconds."
  }
}

variable "geo_locations" {
  type        = list(string)
  default     = ["emea-ru-msa-edge", "emea-se-sto-edge", "emea-gb-db3-azr"]
  description = "List of Azure test locations (provider-specific location strings for UK and Ireland)"
  validation {
    condition     = length(var.geo_locations) >= 1
    error_message = "At least one geo location must be provided."
  }
}

variable "target_url" {
  type        = string
  description = "The target URL for the restful endpoint to hit to validate the application is available"
  validation {
    condition     = can(regex("^https?://", var.target_url))
    error_message = "The target URL must start with http:// or https://."
  }
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

variable "request_body" {
  description = "The request body string; use jsonencode(...) for JSON"
  type        = string
  default     = null
}

variable "alert_description" {
  description = "The description for alert"
  type        = string
  default     = "Availability test alert"
}

variable "ssl_validation" {
  description = <<EOT
The SSL validation settings for the standard web test.

Set `enabled = false` to omit the SSL validation block entirely.
If you want to validate response body text, set content's match to a non-null string.
EOT
  type = object({
    enabled                     = optional(bool, true)
    expected_status_code        = optional(number, 200)
    ssl_check_enabled           = optional(bool, true)
    ssl_cert_remaining_lifetime = optional(number, null)

    content = optional(object({
      match              = string
      ignore_case        = optional(bool, true)
      pass_if_text_found = optional(bool, true)
    }), null)
  })

  validation {
    condition = (
      var.ssl_validation.expected_status_code == 0 ||
      (var.ssl_validation.expected_status_code >= 100 &&
      var.ssl_validation.expected_status_code < 600)
    )
    error_message = "The expected status code must be 0 or a valid HTTP status code in [100, 599]."
  }

  validation {
    condition = (
      var.ssl_validation.ssl_cert_remaining_lifetime == null ||
      (var.ssl_validation.ssl_cert_remaining_lifetime >= 1 &&
      var.ssl_validation.ssl_cert_remaining_lifetime <= 365)
    )
    error_message = "The SSL certificate remaining lifetime must be null or an integer between 1 and 365."
  }

  default = {
    enabled                     = true
    expected_status_code        = 200
    ssl_check_enabled           = true
    ssl_cert_remaining_lifetime = null
    content                     = null
  }
}

variable "alert" {
  type = object({
    frequency             = optional(string, "PT1H")
    window_size           = optional(string, "P1D")
    auto_mitigate         = optional(bool, true)
    failed_location_count = optional(number, 2)
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

  validation {
    condition     = var.alert.failed_location_count >= 1 && var.alert.failed_location_count <= length(var.geo_locations)
    error_message = "The failed location count must be >= 1 and cannot exceed the number of configured geo locations."
  }

  default = {
    frequency     = "PT1H" # every 24 hours
    window_size   = "P1D"  # last 24 hours
    auto_mitigate = true   # automatically mitigate the alert when thie issue is resolved
  }
}
