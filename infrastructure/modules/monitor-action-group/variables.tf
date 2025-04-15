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
  description = "Email receiver properties."
  type = map(object({
    name                    = string
    email_address           = string
    use_common_alert_schema = optional(bool, false)
  }))
  default = {}
}

variable "event_hub_receiver" {
  description = "event hub receiver properties."
  type = map(object({
    name                    = string
    event_hub_namespace     = string
    event_hub_name          = string
    subscription_id         = string
    use_common_alert_schema = bool
  }))
  default = {}
}

variable "sms_receiver" {
  description = "sms receiver properties."
  type = map(object({
    name         = string
    country_code = string
    phone_number = string
  }))
  default = {}
}

variable "voice_receiver" {
  description = "voice receiver properties."
  type = map(object({
    name         = string
    country_code = string
    phone_number = string
  }))
  default = {}
}

variable "webhook_receiver" {
  description = "webhook receiver properties."
  type = map(object({
    name                    = string
    service_uri             = string
    use_common_alert_schema = bool
  }))
  default = {}
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
