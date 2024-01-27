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

resource "azurerm_virtual_network_gateway" "vnetGateways" {
  for_each            = var.properties
  name                = can(each.value.name) ? each.value.name : each.key
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  type                = each.value.type
  vpn_type            = lookup(each.value, "vpn_type", "RouteBased ")
  active_active       = lookup(each.value, "active_active", null)
  enable_bgp          = lookup(each.value, "enable_bgp", false)
  sku                 = each.value.sku

  dynamic "ip_configuration" {
    for_each = each.value.ip_configuration
    content {
      name                          = can(ip_configuration.value.name) ? ip_configuration.value.name : ip_configuration.key
      public_ip_address_id          = ip_configuration.value.public_ip_address_id
      private_ip_address_allocation = lookup(ip_configuration.value, "private_ip_address_allocation", null)
      subnet_id                     = ip_configuration.value.subnet_id
    }
  }
}