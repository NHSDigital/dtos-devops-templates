output "global_uami_id" {
  value = azurerm_user_assigned_identity.global_uami.id
}

output "global_uami_principal_id" {
  value = azurerm_user_assigned_identity.global_uami.principal_id
}

output "assigned_roles" {
  description = "List of role assignments created."
  value = [
    for k, v in azurerm_role_assignment.global_uami_role_assignments :
    {
      id                  = v.id
      role_definition     = v.role_definition_name
      scope               = v.scope
      principal_id        = v.principal_id
    }
  ]
}

output "assigned_roles_by_scope" {
  value = {
    for k, v in azurerm_role_assignment.global_uami_role_assignments :
    "${v.scope}-${v.role_definition_name}" => {
      id           = v.id
      scope        = v.scope
      role         = v.role_definition_name
      principal_id = v.principal_id
    }
  }
}
