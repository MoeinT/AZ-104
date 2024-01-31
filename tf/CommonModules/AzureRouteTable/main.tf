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

resource "azurerm_route_table" "RouteTable" {
  for_each                      = var.properties
  name                          = can(each.value.name) ? each.value.name : each.key
  location                      = each.value.location
  resource_group_name           = each.value.resource_group_name
  disable_bgp_route_propagation = lookup(each.value, "disable_bgp_route_propagation", false)

  dynamic "route" {
    for_each = each.value.route
    content {
      name                   = can(route.value.name) ? route.value.name : route.key
      address_prefix         = route.value.address_prefix
      next_hop_type          = route.value.next_hop_type
      next_hop_in_ip_address = can(route.value.next_hop_in_ip_address) ? route.value.next_hop_in_ip_address : null
    }
  }
}