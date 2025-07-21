variable "resource_group_name" {
  description = "The name of the resource group to deploy Service Health alerts into."
  type        = string
}

variable "subscription_id" {
  description = "Azure subscription ID where the alert will be set."
  type        = string
}

variable "service_health_email_id" {
  description = "Azure monitor action group service health email ID."
  type        = string
}

variable "detector_name" {
  description = "Detector name."
  type        = string
}

variable "severity" {
  description = "severity name."
  type        = number
  default     = 2
}

variable "description" {
  description = "description of the smart detector alert rule."
  type        = string
}
