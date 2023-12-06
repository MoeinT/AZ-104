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


resource "azurerm_lb_rule" "LBrule" {
  for_each                       = var.properties
  name                           = each.key
  loadbalancer_id                = each.value.loadbalancer_id
  protocol                       = each.value.protocol
  frontend_port                  = each.value.frontend_port
  backend_port                   = each.value.backend_port
  backend_address_pool_ids       = lookup(each.value, "backend_address_pool_ids", null)
  frontend_ip_configuration_name = each.value.frontend_ip_configuration_name
  probe_id                       = lookup(each.value, "probe_id", null)
}