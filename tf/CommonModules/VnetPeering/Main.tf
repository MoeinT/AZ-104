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


resource "azurerm_virtual_network_peering" "VnetPeering" {
  for_each                  = var.properties
  name                      = each.key
  resource_group_name       = each.value.resource_group_name
  virtual_network_name      = each.value.virtual_network_name
  remote_virtual_network_id = each.value.remote_virtual_network_id
  allow_forwarded_traffic   = lookup(each.value, "allow_forwarded_traffic", false)
}
