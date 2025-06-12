output "policy_assignment_id" {
  value       = local.assignment_id
  description = "ID of the policy assignment."
}

output "policy_principal_id" {
  value       = local.principal_id
  description = "Principal ID of the system-assigned identity (if created)"
}
