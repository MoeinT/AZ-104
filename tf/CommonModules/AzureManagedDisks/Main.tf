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

resource "azurerm_managed_disk" "disk" {
  for_each             = var.properties
  name                 = each.key
  location             = each.value.location
  resource_group_name  = each.value.resource_group_name
  storage_account_type = each.value.storage_account_type
  create_option        = each.value.create_option
  disk_size_gb         = each.value.disk_size_gb

  tags = can(each.value.tags) ? each.value.tags : {}

}