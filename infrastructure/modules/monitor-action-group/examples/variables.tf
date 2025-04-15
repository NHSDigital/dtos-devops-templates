
variable "monitor_action_group" {
  description = "Default configuration for the monitor action groups."
  type = map(object({
    short_name = string
    email_receiver = optional(map(object({
      name                    = string
      email_address           = string
      use_common_alert_schema = optional(bool, false)
    })))
    event_hub_receiver = optional(map(object({
      name                    = string
      event_hub_namespace     = string
      event_hub_name          = string
      subscription_id         = string
      use_common_alert_schema = optional(bool, false)
    })))
    sms_receiver = optional(map(object({
      name         = string
      country_code = string
      phone_number = string
    })))
    voice_receiver = optional(map(object({
      name         = string
      country_code = string
      phone_number = string
    })))
    webhook_receiver = optional(map(object({
      name                    = string
      service_uri             = string
      use_common_alert_schema = optional(bool, false)
    })))

  }))
}