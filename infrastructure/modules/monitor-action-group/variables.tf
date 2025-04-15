variable "name" {
  type        = string
  description = "value of the name of the diagnostic setting"
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the monitor action group."
  type        = string
}

variable "short_name" {
  description = "The short name of the action group. This will be used in SMS messages."
  type        = string
}

variable "email_receiver" {
  description = "email receiver properties."
  type = list(object({
    name                    = string
    email_address           = string
    use_common_alert_schema = bool
  }))
  default = []
}

variable "webhook_receiver" {
  description = "webhook receiver properties."
  type = list(object({
    name                    = string
    service_uri             = string
    use_common_alert_schema = bool
  }))
  default = []
}

variable "location" {
  description = "The location/region where the Event Hub namespace is created."
  type        = string
  validation {
    condition     = contains(["uksouth", "ukwest"], var.location)
    error_message = "The location must be either uksouth or ukwest."
  }
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
