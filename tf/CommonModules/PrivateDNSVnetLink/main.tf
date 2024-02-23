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

resource "azurerm_private_dns_zone_virtual_network_link" "DNSVnetLinks" {
  for_each              = var.properties
  name                  = lookup(each.value, "name", each.key)
  resource_group_name   = each.value.resource_group_name
  private_dns_zone_name = each.value.private_dns_zone_name
  virtual_network_id    = each.value.virtual_network_id
  registration_enabled  = lookup(each.value, "registration_enabled", false)
}