# Pre-requisite: RBAC assignment at subscription level of role 'Desktop Virtualization Power On Off Contributor' for Service Principal 'Windows Virtual Desktop'
# https://learn.microsoft.com/en-gb/azure/virtual-desktop/autoscale-create-assign-scaling-plan?tabs=portal%2Cintune&pivots=power-management#create-a-custom-rbac-role

# The scaling plan will have zero practical impact without the following changes to the Local Computer Policy in the deployed OS image:
#   - Launch mmc.exe
#   - File > add snap-in > add the Group Policy Objects snap-in, focus it on Local Computer Policy
#   - Navigate to Computer Configuration\Administrative Templates\Windows Components\Remote Desktop Services\Remote Desktop Session Host\Session Time Limits
#   - Set time limit for disconnected sessions (Enabled, 2 hours)
#   - Set time limit for active but idle Remote Desktop Services sessions (Enabled, 1 hour)
#   - End session when time limits are reached (Enabled)

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
    ramp_up_minimum_hosts_percent        = floor(100 / var.vm_count) # a single session host
    ramp_up_capacity_threshold_percent   = 60
    peak_start_time                      = "09:00"
    peak_load_balancing_algorithm        = "BreadthFirst"
    ramp_down_start_time                 = "18:00"
    ramp_down_load_balancing_algorithm   = "DepthFirst"
    ramp_down_minimum_hosts_percent      = floor(100 / var.vm_count) # a single session host
    ramp_down_force_logoff_users         = true
    ramp_down_wait_time_minutes          = 15
    ramp_down_notification_message       = "You will be logged off in 15 mins. Please make sure to save your work."
    ramp_down_capacity_threshold_percent = 80
    ramp_down_stop_hosts_when            = "ZeroActiveSessions"
    off_peak_start_time                  = "22:00"
    off_peak_load_balancing_algorithm    = "DepthFirst"
  }

  host_pool {
    hostpool_id          = azurerm_virtual_desktop_host_pool.this.id
    scaling_plan_enabled = true
  }
}
