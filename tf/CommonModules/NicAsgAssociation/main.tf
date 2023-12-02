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

resource "azurerm_network_interface_application_security_group_association" "NicAsgAssociation" {
  for_each                      = var.properties
  network_interface_id          = each.value.network_interface_id
  application_security_group_id = each.value.application_security_group_id
}