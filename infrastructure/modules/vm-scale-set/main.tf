resource "azurerm_orchestrated_virtual_machine_scale_set" "vmss" {
  name                        = var.vmss_name
  location                    = var.location
  resource_group_name         = var.rg_name
  platform_fault_domain_count = 1
  sku_name                    = var.sku_name
  encryption_at_host_enabled  = true # needs 'az feature register --name EncryptionAtHost  --namespace Microsoft.Compute'
  instances                   = 1

  network_interface {
    name = "nic01"
    # network_security_group_id = # not needed since there is an NSG on the subnet
    primary = true

    ip_configuration {
      name                                   = "nic01-ipcfg"
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.vmss_beap.id]
      primary                                = true
      subnet_id                              = azurerm_subnet.vmss_subnet.id
    }
  }

  os_profile {
    linux_configuration {
      computer_name_prefix            = var.vmss_name
      admin_username                  = "azureadmin"
      admin_password                  = var.vm_passwd
      disable_password_authentication = false
    }
  }

  os_disk {
    caching              = "ReadWrite"
    disk_size_gb         = 30
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    offer     = "ubuntu-24_04-lts"
    publisher = "canonical"
    sku       = "server"
    version   = "latest"
  }

  zones        = ["1", "2", "3"]
  zone_balance = true
}


resource "azurerm_monitor_autoscale_setting" "autoscale" {
  name                = "${var.vmss_name}-autoscale"
  resource_group_name = var.rg_name
  location            = var.location
  target_resource_id  = azurerm_orchestrated_virtual_machine_scale_set.vmss.id

  profile {
    name = "Default"

    capacity {
      default = 1
      minimum = 1
      maximum = 3
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_orchestrated_virtual_machine_scale_set.vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT10M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 80
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = 1
        cooldown  = "PT5M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_orchestrated_virtual_machine_scale_set.vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT10M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 20
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = 1
        cooldown  = "PT5M"
      }
    }
  }
}
