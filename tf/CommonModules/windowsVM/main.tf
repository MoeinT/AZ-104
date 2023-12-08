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


# Define the Virtual Machine
resource "azurerm_windows_virtual_machine" "AppVm" {
  for_each              = var.properties
  name                  = each.key
  resource_group_name   = each.value.resource_group_name
  location              = each.value.location
  size                  = lookup(each.value, "size", "Standard_B1s")
  admin_username        = each.value.admin_username
  admin_password        = each.value.admin_password
  network_interface_ids = each.value.network_interface_ids
  availability_set_id   = lookup(each.value, "availability_set_id", null)


  os_disk {
    caching              = "None"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
}