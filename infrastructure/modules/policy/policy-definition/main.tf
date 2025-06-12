resource "azurerm_policy_definition" "item" {
  name         = var.name
  policy_type  = coalesce(var.policy_type, "custom")
  mode         = coalesce(var.mode, "all")
  display_name = var.display_name
  description  = var.description
  metadata = try(jsonencode(merge({
    "category" : "Security",
    "version" : "1.0",
    "owner" : "security-team@nhs.net"
    },
  var.metadata)))
  parameters  = try(length(var.parameters) > 0 ? jsonencode(var.parameters) : null, null)
  policy_rule = jsonencode(var.policy_rule)
}

locals {
  requires_identity = contains(["deployIfNotExists", "modify", "append"], var.policy_rule.then.effect)
}

