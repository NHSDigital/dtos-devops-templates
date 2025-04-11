resource "azurerm_network_interface" "this" {
  count = var.vm_count

  name                = "${var.vm_name_prefix}-${random_string.suffix[count.index].result}_nic"
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

resource "random_string" "suffix" {
  count = var.vm_count

  length  = 5
  upper   = false
  special = false
}

resource "azurerm_windows_virtual_machine" "this" {
  count = var.vm_count

  name                       = "${var.vm_name_prefix}-${random_string.suffix[count.index].result}"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  network_interface_ids      = [azurerm_network_interface.this[count.index].id]
  size                       = var.vm_size
  admin_username             = "azureadmin"
  admin_password             = random_password.admin_password.result
  computer_name              = "${var.computer_name_prefix}${random_string.suffix[count.index].result}"
  license_type               = var.vm_license_type
  encryption_at_host_enabled = true # az feature register --namespace Microsoft.Compute --name EncryptionAtHost
  secure_boot_enabled        = true
  vtpm_enabled               = true

  identity {
    type = "SystemAssigned"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.vm_storage_account_type
    disk_size_gb         = var.vm_disk_size
  }

  dynamic "source_image_reference" {
    for_each = var.source_image_reference != null && var.source_image_from_gallery == null ? [1] : []

    content {
      publisher = var.source_image_reference.publisher
      offer     = var.source_image_reference.offer
      sku       = var.source_image_reference.sku
      version   = var.source_image_reference.version
    }
  }

  source_image_id = var.source_image_id != null ? var.source_image_id : (
    var.source_image_from_gallery != null && var.source_image_reference == null ? data.azurerm_shared_image.gallery_image[0].id : null
  )

  termination_notification {
    enabled = true
  }

  tags = merge(
    var.tags,
    {
      EnablePrivateNetworkGC = "TRUE" # mandated by Azure Policy
    }
  )
}

resource "azurerm_virtual_machine_extension" "aadjoin" {
  count = var.vm_count

  name                       = "AADJoin"
  virtual_machine_id         = azurerm_windows_virtual_machine.this[count.index].id
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADLoginForWindows"
  type_handler_version       = "2.0"
  auto_upgrade_minor_version = true
}

resource "azurerm_virtual_machine_extension" "azurepolicy" {
  count = var.vm_count

  name                       = "AzurePolicyforWindows"
  virtual_machine_id         = azurerm_windows_virtual_machine.this[count.index].id
  publisher                  = "Microsoft.GuestConfiguration"
  type                       = "ConfigurationforWindows"
  type_handler_version       = "1.1"
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
  settings                   = jsonencode({})
}

resource "azurerm_virtual_machine_extension" "guestattestation" {
  count = var.vm_count

  name                       = "GuestAttestation"
  virtual_machine_id         = azurerm_windows_virtual_machine.this[count.index].id
  publisher                  = "Microsoft.Azure.Security.WindowsAttestation"
  type                       = "GuestAttestation"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true

  settings = jsonencode({
    AttestationConfig = {
      MaaSettings = {
        maaEndpoint   = ""
        maaTenantName = "GuestAttestation"
      }
      AscSettings = {
        ascReportingEndpoint  = ""
        ascReportingFrequency = ""
      }
      useCustomToken = "false"
      disableAlerts  = "false"
    }
  })
}

resource "azurerm_virtual_machine_extension" "hostpooljoin" {
  count = var.vm_count

  name                       = "DesiredStateConfiguration"
  virtual_machine_id         = azurerm_windows_virtual_machine.this[count.index].id
  publisher                  = "Microsoft.Powershell"
  type                       = "DSC"
  type_handler_version       = "2.73"
  auto_upgrade_minor_version = true

  settings = jsonencode({
    modulesUrl            = "https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_1.0.02797.442.zip"
    configurationFunction = "Configuration.ps1\\AddSessionHost"
    properties = {
      HostPoolName             = azurerm_virtual_desktop_host_pool.this.name
      aadJoin                  = true
      UseAgentDownloadEndpoint = true
    }
  })

  protected_settings = jsonencode({
    properties = {
      registrationInfoToken = azurerm_virtual_desktop_host_pool_registration_info.registrationinfo.token
    }
  })

  lifecycle {
    ignore_changes = [settings, protected_settings]
  }

  depends_on = [azurerm_virtual_machine_extension.aadjoin]
}

data "azurerm_shared_image" "gallery_image" {
  count = var.source_image_from_gallery != null ? 1 : 0

  name                = var.source_image_from_gallery.image_name
  gallery_name        = var.source_image_from_gallery.gallery_name
  resource_group_name = var.source_image_from_gallery.gallery_rg_name
}
