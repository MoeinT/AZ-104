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


# Associate the security group to the network interface
resource "azurerm_network_interface_security_group_association" "NIC_NSG" {
  for_each                  = var.properties
  network_interface_id      = each.value.network_interface_id
  network_security_group_id = each.value.network_security_group_id
}