resource "azurerm_network_interface" "this" {
  count = var.vm_count

  name                = "nic-session-host"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}

resource "random_password" "admin_password" {
  length           = 16
  special          = true
  override_special = "!@#$%^&*()-_=+[]{}<>:?"
}

resource "azurerm_windows_virtual_machine" "this" {
  count = var.vm_count

  name                              = "${var.vm_hostname_prefix}-${count.index}"
  location                          = var.location
  resource_group_name               = var.resource_group_name
  network_interface_ids             = [azurerm_network_interface.this[count.index].id]
  size                              = var.vm_size
  admin_username                    = "azureadmin"
  admin_password                    = random_password.admin_password.result
  encryption_at_host_enabled        = true
  patch_mode                        = "AutomaticByPlatform"
  hotpatching_enabled               = true
  patch_assessment_mode             = "AutomaticByPlatform"
  reboot_setting                    = "IfRequired"
  secure_boot_enabled               = true
  vtpm_enabled                      = true
  vm_agent_platform_updates_enabled = true

  identity {
    type = "SystemAssigned"
  }

  os_disk {
    name                 = "OS_DISK"
    caching              = "ReadWrite"
    storage_account_type = var.vm_storage_account_type
    disk_size_gb         = var.vm_disk_size
  }

  storage_image_reference {
    publisher = "microsoftwindowsdesktop" # Windows 11 multi-session
    offer     = "windows-11"
    sku       = "win11-23h2-avd"
    version   = "latest"
  }

  termination_notification {
    enable = true
  }

  tags = var.tags
}

resource "azurerm_virtual_machine_extension" "aadjoin" {
  count = var.vm_count

  name                 = "AADJoin"
  virtual_machine_id   = azurerm_windows_virtual_machine.this[count.index].id
  publisher            = "Microsoft.Azure.ActiveDirectory"
  type                 = "AADLoginForWindows"
  type_handler_version = "1.0"

  settings = jsonencode({
    properties = {}
  })
}

resource "azurerm_virtual_machine_extension" "avd_registration" {
  count = var.vm_count

  name                 = "avd-registration"
  virtual_machine_id   = azurerm_windows_virtual_machine.this[count.index].id
  publisher            = "Microsoft.DesktopVirtualization"
  type                 = "ds_agent"
  type_handler_version = "1.0"

  settings = jsonencode({
    "registrationInfo" = {
      "token" = azurerm_virtual_desktop_host_pool_registration_info.registrationinfo.token
    }
  })
}
