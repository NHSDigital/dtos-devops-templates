resource "azurerm_role_definition" "avd_rbac" {
  name        = "AVD-AutoScale"
  scope       = var.resource_group_id
  description = "AVD AutoScale Role"
  permissions {
    actions = [
      "Microsoft.Insights/eventtypes/values/read",
      "Microsoft.Compute/virtualMachines/deallocate/action",
      "Microsoft.Compute/virtualMachines/restart/action",
      "Microsoft.Compute/virtualMachines/powerOff/action",
      "Microsoft.Compute/virtualMachines/start/action",
      "Microsoft.Compute/virtualMachines/read",
      "Microsoft.DesktopVirtualization/hostpools/read",
      "Microsoft.DesktopVirtualization/hostpools/write",
      "Microsoft.DesktopVirtualization/hostpools/sessionhosts/read",
      "Microsoft.DesktopVirtualization/hostpools/sessionhosts/write",
      "Microsoft.DesktopVirtualization/hostpools/sessionhosts/usersessions/delete",
      "Microsoft.DesktopVirtualization/hostpools/sessionhosts/usersessions/read",
      "Microsoft.DesktopVirtualization/hostpools/sessionhosts/usersessions/sendMessage/action",
      "Microsoft.DesktopVirtualization/hostpools/sessionhosts/usersessions/read"
    ]
    not_actions = []
  }
  assignable_scopes = [
    var.resource_group_id
  ]
}

data "azuread_service_principal" "avd_sp" {
  display_name = "Azure Virtual Desktop"
}

resource "azurerm_role_assignment" "avd_rbac_assign" {
  scope                            = var.resource_group_id
  role_definition_id               = azurerm_role_definition.avd_rbac.role_definition_resource_id
  principal_id                     = data.azuread_service_principal.avd_sp.id
  skip_service_principal_aad_check = true
}

resource "azurerm_virtual_desktop_scaling_plan" "this" {
  name                = var.scaling_plan_name
  location            = var.location
  resource_group_name = var.resource_group_name
  time_zone           = "GMT Standard Time"
  schedule {
    name                                 = "Weekdays"
    days_of_week                         = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
    ramp_up_start_time                   = "07:00"
    ramp_up_load_balancing_algorithm     = "BreadthFirst"
    ramp_up_minimum_hosts_percent        = 15
    ramp_up_capacity_threshold_percent   = 60
    peak_start_time                      = "09:00"
    peak_load_balancing_algorithm        = "BreadthFirst"
    ramp_down_start_time                 = "18:00"
    ramp_down_load_balancing_algorithm   = "DepthFirst"
    ramp_down_minimum_hosts_percent      = 15
    ramp_down_force_logoff_users         = true
    ramp_down_wait_time_minutes          = 30
    ramp_down_notification_message       = "You will be logged off in 30 min. Please make sure to save your work."
    ramp_down_capacity_threshold_percent = 90
    ramp_down_stop_hosts_when            = "ZeroActiveSessions"
    off_peak_start_time                  = "19:00"
    off_peak_load_balancing_algorithm    = "DepthFirst"
  }
  host_pool {
    hostpool_id          = azurerm_virtual_desktop_host_pool.this.id
    scaling_plan_enabled = true
  }
}