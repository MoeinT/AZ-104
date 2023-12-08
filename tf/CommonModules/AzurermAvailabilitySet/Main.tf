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

resource "azurerm_availability_set" "AllAvailabilitySets" {
  for_each                     = var.properties
  name                         = each.key
  location                     = each.value.location
  resource_group_name          = each.value.resource_group_name
  managed                      = lookup(each.value, "managed", true)
  platform_update_domain_count = lookup(each.value, "platform_update_domain_count", 5)
  platform_fault_domain_count  = lookup(each.value, "platform_fault_domain_count", 3)
  tags                         = lookup(each.value, "tags", null)
}