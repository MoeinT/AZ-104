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

resource "azurerm_subnet_network_security_group_association" "NSGSubnetAttachment" {
  for_each                  = var.properties
  subnet_id                 = each.value.subnet_id
  network_security_group_id = each.value.network_security_group_id
}