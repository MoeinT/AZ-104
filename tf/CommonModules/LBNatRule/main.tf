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


resource "azurerm_lb_nat_rule" "NatRule" {
  for_each                       = var.properties
  name                           = each.key
  resource_group_name            = each.value.resource_group_name
  loadbalancer_id                = each.value.loadbalancer_id
  protocol                       = each.value.protocol
  frontend_port                  = lookup(each.value, "frontend_port", null)
  backend_port                   = each.value.backend_port
  frontend_ip_configuration_name = each.value.frontend_ip_configuration_name
  backend_address_pool_id        = lookup(each.value, "backend_address_pool_id", null)
  frontend_port_start            = lookup(each.value, "frontend_port_start", null)
  frontend_port_end              = lookup(each.value, "frontend_port_end", null)
}