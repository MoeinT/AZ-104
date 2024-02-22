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

resource "azurerm_virtual_network" "Vnet" {
  for_each            = var.properties
  name                = each.key
  address_space       = each.value.address_space
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  
  lifecycle {
    ignore_changes = [dns_servers]
  }
}