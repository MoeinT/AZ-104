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


resource "azurerm_lb" "LBs" {
  for_each            = var.properties
  name                = each.key
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  sku                 = lookup(each.value, "sku", "Basic")

  dynamic "frontend_ip_configuration" {
    for_each = each.value.frontend_ip_configuration
    content {
      name                 = frontend_ip_configuration.key
      subnet_id            = lookup(frontend_ip_configuration.value, "subnet_id", null)
      public_ip_address_id = lookup(frontend_ip_configuration.value, "public_ip_address_id", null)
      private_ip_address   = lookup(frontend_ip_configuration.value, "private_ip_address", null)
    }
  }
}