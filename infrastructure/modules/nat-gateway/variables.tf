variable "name" {
  description = "The name of the NAT gateway."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9.-]{0,78}[a-zA-Z0-9]$", var.name))
    error_message = "The NAT gateway name must be between 2 and 80 characters, start and end with an alphanumeric character, and can contain alphanumeric characters, hyphens, and periods."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the NAT gateway."
  type        = string
}

variable "location" {
  description = "The location/region where the NAT gateway will be created."
  type        = string
  default     = "uksouth"
  validation {
    condition     = contains(["uksouth", "ukwest"], var.location)
    error_message = "The location must be either uksouth or ukwest."
  }
}

variable "public_ip_name" {
  description = "The name of the public IP address resource created for the NAT gateway."
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet to associate with the NAT gateway."
  type        = string
}

variable "idle_timeout_in_minutes" {
  description = "The idle timeout in minutes for the NAT gateway. Must be between 4 and 120."
  type        = number
  default     = 4
  validation {
    condition     = var.idle_timeout_in_minutes >= 4 && var.idle_timeout_in_minutes <= 120
    error_message = "idle_timeout_in_minutes must be between 4 and 120."
  }
}

variable "zones" {
  description = "Availability zones for the NAT gateway and its public IP. Use [\"1\"] for a zonal deployment. An empty list deploys with no zone redundancy."
  type        = list(string)
  default     = []
  validation {
    condition     = length(var.zones) <= 1
    error_message = "NAT gateway supports at most one availability zone."
  }
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
