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