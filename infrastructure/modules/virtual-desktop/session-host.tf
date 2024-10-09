resource "azurerm_network_interface" "this" {
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

resource "azurerm_virtual_machine" "this" {
  name                  = "vm-session-host"
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.this.id]
  vm_size               = "Standard_D2as_v5"

  storage_os_disk {
    name              = "osdisk-session-host"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "StandardSSD_LRS"
  }

  storage_image_reference {
    publisher = "microsoftwindowsdesktop" # Windows 11 multi-session
    offer     = "windows-11"
    sku       = "win11-23h2-avd"
    version   = "latest"
  }

  os_profile {
    computer_name  = "avdhost-0"
    admin_username = "azureadmin"
    admin_password = random_password.admin_password.result # use a more secure password or secret
  }

  os_profile_windows_config {}

  # Assign to the AVD Host Pool
  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

resource "azurerm_virtual_machine_extension" "aad_login_extension" {
  name                 = "AADLoginForWindows"
  virtual_machine_id   = azurerm_virtual_machine.this.id
  publisher            = "Microsoft.Azure.ActiveDirectory"
  type                 = "AADLoginForWindows"
  type_handler_version = "1.0"

  settings = jsonencode({
    "properties": {}
  })
}

resource "azurerm_virtual_machine_extension" "avd_registration" {
  name                 = "avd-registration"
  virtual_machine_id   = azurerm_virtual_machine.this.id
  publisher            = "Microsoft.DesktopVirtualization"
  type                 = "ds_agent"
  type_handler_version = "1.0"

  settings = jsonencode({
    "registrationInfo" = {
      "token" = azurerm_virtual_desktop_host_pool_registration_info.registrationinfo.token
    }
  })
}
