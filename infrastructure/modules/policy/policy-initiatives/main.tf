resource "azurerm_policy_set_definition" "item" {
  count = length(var.policy_definitions) > 1 ? 1 : 0

  name         = var.name
  display_name = var.display_name
  policy_type  = var.policy_type
  description  = var.description

  dynamic "policy_definition_reference" {
    for_each = var.policy_definitions
    content {
      policy_definition_id = policy_definition_reference.value.id
      parameter_values     = lookup(policy_definition_reference.value, "parameters", null)
      reference_id         = lookup(policy_definition_reference.value, "reference_id", null)
    }
  }
}
