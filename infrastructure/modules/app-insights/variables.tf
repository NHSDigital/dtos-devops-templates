
variable "location" {
  type        = string
  description = "The location/region where the AI is created."
}

variable "name" {
  type        = string
  description = "Is the App Insights workspace name."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A mapping of tags to assign to the resource."
}

variable "appinsights_type" {
  type        = string
  description = "Type of Application Insights (default: web)."
  default     = "web"
  validation {
    condition = contains([
      "ios",
      "java",
      "MobileCenter",
      "Node.JS",
      "other",
      "phone",
      "store",
      "web",
    ], var.appinsights_type)
    error_message = "The appinsights_type must be one of the following: 'ios', 'java', 'MobileCenter', 'Node.JS', 'other', 'phone', 'store', or 'web' (case-sensitive)."
  }
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Is the LAW workspace ID in Audit subscription."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which the App Insights is created. Changing this forces a new resource to be created."
}
