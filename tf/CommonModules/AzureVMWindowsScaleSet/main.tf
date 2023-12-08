terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}


resource "azurerm_windows_virtual_machine_scale_set" "VMScaleSets" {
  for_each             = var.properties
  name                 = each.key
  resource_group_name  = each.value.resource_group_name
  location             = each.value.location
  sku                  = each.value.sku
  instances            = each.value.instances
  admin_password       = each.value.admin_password
  admin_username       = each.value.admin_username
  computer_name_prefix = each.value.computer_name_prefix

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }

  os_disk {
    caching              = "None"
    storage_account_type = "Standard_LRS"
  }

  network_interface {
    name                      = each.value.network_interface.name
    primary                   = lookup(each.value.network_interface, "primary", false)
    network_security_group_id = lookup(each.value.network_interface, "network_security_group_id", null)

    ip_configuration {
      name                                   = each.value.network_interface.ip_configuration.name
      primary                                = each.value.network_interface.ip_configuration.primary
      subnet_id                              = each.value.network_interface.ip_configuration.subnet_id
      application_security_group_ids         = lookup(each.value.network_interface.ip_configuration, "application_security_group_ids", null)
      load_balancer_backend_address_pool_ids = lookup(each.value.network_interface.ip_configuration, "load_balancer_backend_address_pool_ids", null)
      dynamic "public_ip_address" {
        for_each = can(each.value.network_interface.ip_configuration.public_ip_address) ? [1] : []
        content {
          name              = each.value.network_interface.ip_configuration.public_ip_address.name
          domain_name_label = lookup(each.value.network_interface.ip_configuration.public_ip_address, "domain_name_label", null)
        }
      }
    }
  }
}