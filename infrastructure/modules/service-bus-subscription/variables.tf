variable "subscription_name" {
  description = "The name of the Service Bus subscription."
  type        = string

  validation {
    condition     = length(var.subscription_name) > 0 && length(var.subscription_name) <= 50
    error_message = "subscription_name must be between 1 and 50 characters."
  }
}

variable "topic_id" {
  description = "The name of the Service Bus topic."
  type        = string

  # validation {
  #   condition     = length(var.topic_name) > 0 && length(var.topic_name) <= 50
  #   error_message = "topic_name must be between 1 and 50 characters."
  # }
}

variable "namespace_name" {
  description = "The name of the Service Bus namespace."
  type        = string

  validation {
    condition     = length(var.namespace_name) > 0 && length(var.namespace_name) <= 50
    error_message = "namespace_name must be between 1 and 50 characters."
  }
}

variable "max_delivery_count" {
  description = "The maximum delivery count of a message before it is dead-lettered."
  type        = number
  default     = 10

  validation {
    condition     = var.max_delivery_count > 0 && var.max_delivery_count <= 100
    error_message = "max_delivery_count must be between 1 and 100."
  }
}

variable "service_bus_namespace_id" {
  description = "The ID of the Service Bus namespace resource for role assignment scope."
  type        = string

  validation {
    condition     = can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft.ServiceBus/namespaces/.+$", var.service_bus_namespace_id))
    error_message = "service_bus_namespace_id must be a valid Azure Service Bus namespace resource ID."
  }
}

variable "function_app_principal_id" {
  description = "The principal ID (object ID) of the Function App's managed identity."
  type        = string

  validation {
    condition     = length(var.function_app_principal_id) == 36 || length(var.function_app_principal_id) == 32
    error_message = "function_app_principal_id should be a valid GUID string."
  }
}
