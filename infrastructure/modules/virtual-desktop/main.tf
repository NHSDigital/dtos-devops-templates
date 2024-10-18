resource "azurerm_virtual_desktop_workspace" "this" {
  name                = var.workspace_name
  resource_group_name = var.resource_group_name
  location            = var.location
  friendly_name       = var.workspace_friendly_name
  description         = var.workspace_description

  tags = var.tags
}

resource "azurerm_virtual_desktop_host_pool" "this" {
  resource_group_name      = var.resource_group_name
  location                 = var.location
  name                     = var.host_pool_name
  friendly_name            = var.host_pool_friendly_name
  description              = var.host_pool_description
  validate_environment     = var.validate_environment
  custom_rdp_properties    = var.custom_rdp_properties
  type                     = var.host_pool_type
  maximum_sessions_allowed = var.maximum_sessions_allowed
  load_balancer_type       = var.load_balancer_type

  scheduled_agent_updates {
    enabled = true
    schedule {
      day_of_week = "Saturday"
      hour_of_day = 2
    }
  }

  tags = var.tags
}

resource "azurerm_virtual_desktop_host_pool_registration_info" "registrationinfo" {
  hostpool_id     = azurerm_virtual_desktop_host_pool.this.id
  expiration_date = timeadd(timestamp(), "24h")
}

resource "azurerm_virtual_desktop_application_group" "this" {
  resource_group_name = var.resource_group_name
  location            = var.location
  host_pool_id        = azurerm_virtual_desktop_host_pool.this.id
  type                = var.dag_type
  name                = var.dag_name
  friendly_name       = var.dag_friendly_name
  description         = var.dag_description
  depends_on          = [azurerm_virtual_desktop_workspace.this]

  tags = var.tags
}

resource "azurerm_virtual_desktop_workspace_application_group_association" "this" {
  application_group_id = azurerm_virtual_desktop_application_group.this.id
  workspace_id         = azurerm_virtual_desktop_workspace.this.id
}

resource "azurerm_role_assignment" "rg" {
  scope                = var.resource_group_id
  role_definition_name = "Virtual Machine User Login"
  principal_id         = var.login_principal_id
}

resource "azurerm_role_assignment" "dag" {
  scope                = azurerm_virtual_desktop_application_group.this.id
  role_definition_name = "Desktop Virtualization User"
  principal_id         = var.login_principal_id
}
