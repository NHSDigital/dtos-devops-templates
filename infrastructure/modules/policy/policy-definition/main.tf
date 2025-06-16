resource "azurerm_policy_definition" "item" {
  name         = var.policy_name
  display_name = var.display_name
  description  = var.description

  policy_type  = coalesce(var.policy_type, "custom")
  mode         = coalesce(var.mode, "all")

  metadata      = jsonencode(var.metadata)

  parameters  = try(length(var.parameters) > 0 ? jsonencode(var.parameters) : null, null)

  policy_rule = jsonencode({
    if = {
      anyOf = local.policy_conditions
    }
    then = {
      effect = var.policy_effect
      details = {
        roleDefinitionIds = [
          # Contributor role
          "/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
        ]
        operations = local.policy_operations
      }
    }
  })
}

locals {
  requires_identity = contains(["deployIfNotExists", "modify", "append"], var.policy_effect)

  # A list similar to
  # {
  #   field  = "[concat('tags[', parameters('tagName1'), '')]"
  #   exists = "false"
  # }
  policy_conditions = length(var.policy_conditions) > 0 ? var.policy_conditions : [
    # default goes here
  ]

  # A list similar to
  # {
  #   operation = "add"
  #   field     = "[concat('tags[', parameters('tagName1'), '')]"
  #   value     = "[resourceGroup().tags[parameters('tagName1')]]"
  # }
  policy_operations = length(var.policy_operations) > 0 ? var.policy_operations : [
    # default goes here
  ]

  # Example
  # tagName1 = {
  #   type = "String"
  #   metadata = {
  #     displayName = "Tag Name"
  #     description = "Name of the tag to inherit"
  #   }
  # }
  parameters = length(var.parameters) > 0 ? var.parameters : {
    # default goes here
  }
}

