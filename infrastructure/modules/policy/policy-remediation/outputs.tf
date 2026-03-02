output "policy_remediation_id" {
  value       = azurerm_resource_policy_remediation.remediation.id
  description = "The ID of the created policy remediation."
}
