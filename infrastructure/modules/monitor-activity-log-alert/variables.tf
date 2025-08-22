variable "name" {
  type        = string
  description = "Name of the activity log alert."
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name."
}

variable "scopes" {
  type        = list(string)
  description = "List of scopes (usually one or more subscription IDs)."
}

variable "description" {
  type        = string
  description = "Description of the alert."
  default     = "Activity log alert for Service Health events"
}

variable "enabled" {
  type    = bool
  default = true
}

variable "action_group_id" {
  type        = string
  description = "ID of the action group to notify."
}

variable "webhook_properties" {
  type    = map(string)
  default = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "location" {
  type        = string
  description = "Azure region where the activity log alert is deployed (any valid region)."
  default     = "UK South"
}

variable "criteria" {
  description = "Criteria for the activity log alert"
  type = object({
    category = string
    level    = string
    service_health = optional(object({
      events    = list(string)
      locations = list(string)
      services  = optional(list(string))
    }))
  })
}
