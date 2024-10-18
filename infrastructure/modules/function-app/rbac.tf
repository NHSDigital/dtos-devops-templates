module "rbac_assignmnents" {
  for_each = { for idx, assignment in var.rbac_role_assignments : idx => assignment }


  source = "git::https://github.com/NHSDigital/dtos-devops-templates.git//infrastructure/modules/rbac-assignment?ref=feat/DTOSS-0000-Function-App-Security-Updates"

  principal_id         = azurerm_linux_function_app.function_app.identity.0.principal_id
  role_definition_name = each.value.role_definition_name
  scope                = each.value.scope
}