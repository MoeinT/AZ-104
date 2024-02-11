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

resource "azurerm_firewall_policy" "FirewallPolicies" {
  for_each            = var.properties
  name                = can(each.value.name) ? each.value.name : each.key
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  sku                 = lookup(each.value, "sku", "Standard")
}