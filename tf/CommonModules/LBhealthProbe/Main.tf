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

resource "azurerm_lb_probe" "LBhealthProbe" {
  for_each            = var.properties
  name                = each.key
  loadbalancer_id     = each.value.loadbalancer_id
  port                = each.value.port
  protocol            = lookup(each.value, "protocol", null)
  interval_in_seconds = lookup(each.value, "interval_in_seconds", null)
}