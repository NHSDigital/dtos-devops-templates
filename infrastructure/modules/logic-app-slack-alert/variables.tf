variable "name" {
  type        = string
  description = "Name of the Logic App workflow."
}

variable "resource_group_name" {
  type        = string
  description = "Resource group in which to create the Logic App."
}

variable "location" {
  type        = string
  description = "Azure region in which to create the Logic App."
}

variable "slack_webhook_url" {
  type        = string
  description = "Slack incoming webhook URL. Stored as a SecureString workflow parameter."
  sensitive   = true
}
