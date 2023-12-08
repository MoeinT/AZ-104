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

# Provision a Linux Virtual Machine
resource "azurerm_linux_virtual_machine" "AppLinuxVm" {
  for_each              = var.properties
  name                  = each.key
  resource_group_name   = each.value.resource_group_name
  location              = each.value.location
  size                  = each.value.size
  admin_username        = each.value.admin_username
  network_interface_ids = each.value.network_interface_ids
  availability_set_id   = lookup(each.value, "availability_set_id", null)
  # Optionally add an admin password
  admin_password = lookup(each.value, "admin_password", null)
  # When an admin_password is specified disable_password_authentication must be set to false
  disable_password_authentication = can(each.value.admin_password) ? false : true

  # Optionally add an ssh key
  dynamic "admin_ssh_key" {
    for_each = can(each.value.admin_ssh_key.username) && can(each.value.admin_ssh_key.public_key) ? [1] : []
    content {
      username   = each.value.admin_ssh_key.username
      public_key = each.value.admin_ssh_key.public_key
    }
  }

  os_disk {
    caching              = can(each.value.os_disk.caching) ? each.value.os_disk.caching : "None"
    storage_account_type = can(each.value.os_disk.storage_account_type) ? each.value.os_disk.storage_account_type : "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}