variable "name" {
  description = "Name of the container app environment."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group to create the container app environment in."
  type        = string
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "ID of the log analytics workspace to send resource logging to via diagnostic settings"
}

variable "vnet_integration_subnet_id" {
  type        = string
  description = "ID of the subnet for the container app environment. Must be at least /23"
}
