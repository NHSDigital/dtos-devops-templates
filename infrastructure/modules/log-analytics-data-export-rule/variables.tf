variable "name" {
  description = "The name of the Log Analytics Data Export Rule."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Log Analytics Data Export Rule."
  type        = string
}

variable "destination_resource_id" {
  description = "The resource ID of the destination where the data will be exported."
  type        = string
}

variable "enabled" {
  description = "Whether the data export rule is enabled."
  type        = bool
}

variable "table_names" {
  description = "A list of table names to export data from."
  type        = list(string)
}

variable "workspace_resource_id" {
  description = "The resource ID of the Log Analytics workspace."
  type        = string
}
