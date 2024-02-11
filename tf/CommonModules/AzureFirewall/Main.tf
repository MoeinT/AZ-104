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

# Azure Firewall
resource "azurerm_firewall" "AzureFireWall" {
  for_each            = var.properties
  name                = can(each.value.name) ? each.value.name : each.key
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  sku_name            = each.value.sku_name
  sku_tier            = each.value.sku_tier
  firewall_policy_id  = lookup(each.value, "firewall_policy_id", null)

  # An optional ip_configuration block
  dynamic "ip_configuration" {
    for_each = can(each.value.ip_configuration) ? [1] : []
    content {
      name                 = each.value.ip_configuration.name
      subnet_id            = lookup(each.value.ip_configuration, "subnet_id", null)
      public_ip_address_id = lookup(each.value.ip_configuration, "public_ip_address_id", null)
    }
  }
}