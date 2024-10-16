module "rbac_assignmnents" {
  for_each = var.rbac_role_assignments

  source = "git::https://github.com/NHSDigital/dtos-devops-templates.git//infrastructure/modules/rbac-assignment?ref=08100f7db2da6c0f64f327d15477a217a7ed4cd9"

  principal_id         = azurerm_linux_function_app.function_app.identity.0.principal_id
  role_definition_name = each.value.role_definition_name
  scope                = each.value.scope
}
