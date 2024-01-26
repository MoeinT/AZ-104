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

resource "azurerm_bastion_host" "AllBastionHosts" {
  for_each            = var.properties
  name                = can(each.value.name) ? each.value.name : each.key
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  sku                 = lookup(each.value, "sku", "Basic")
  copy_paste_enabled  = lookup(each.value, "copy_paste_enabled", null)
  file_copy_enabled   = lookup(each.value, "file_copy_enabled", null)

  ip_configuration {
    name                 = each.value.ip_configuration.name
    subnet_id            = each.value.ip_configuration.subnet_id
    public_ip_address_id = each.value.ip_configuration.public_ip_address_id
  }
}