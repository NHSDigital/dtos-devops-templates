output "policy_definition_id" {
  value       = azurerm_policy_definition.definition.id
  description = "The ID of the created policy definition."
}

output "policy_requires_identity" {
  value       = local.requires_identity
  description = "True if this policy must be assigned a managed identity, false otherwise"
}
