output "initiative_id" {
  value       = try(azurerm_policy_set_definition.item[0].id, null)
  description = "ID of the created policy initiative."
}
