variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the Event Grid. Changing this forces a new resource to be created."
}

variable "location" {
  type        = string
  description = "The location/region where the Event Grid is created."
}

variable "inbound_ip_rules" {
  description = "List of inbound IP rules"
  type = list(object({
    ip_mask = string
    action  = string
  }))
  default = []
}

variable "identity_type" {
  type        = string
  description = "The identity type of the Event Grid."
}

variable "topic_name" {
  description = "The name of the Event Grid topic."
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to the Event Grid topic."
  type        = map(string)
  default     = {}
}
