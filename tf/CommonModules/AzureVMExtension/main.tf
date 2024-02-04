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

resource "azurerm_virtual_machine_extension" "AllExtensions" {
  for_each = var.properties
  name                       = can(each.value.name) ? each.value.name : each.key
  virtual_machine_id         = each.value.virtual_machine_id
  publisher                  = each.value.publisher
  type                       = each.value.type
  type_handler_version       = each.value.type_handler_version
  auto_upgrade_minor_version = each.value.auto_upgrade_minor_version
}