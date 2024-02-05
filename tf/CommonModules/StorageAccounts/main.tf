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

resource "azurerm_storage_account" "AllSa" {
  for_each                        = var.properties
  name                            = can(each.value.name) ? each.value.name : each.key
  resource_group_name             = each.value.resource_group_name
  location                        = each.value.location
  account_tier                    = each.value.account_tier
  is_hns_enabled                  = lookup(each.value, "true", true)
  account_replication_type        = lookup(each.value, "account_replication_type", "LRS")
  allow_nested_items_to_be_public = lookup(each.value, "allow_nested_items_to_be_public", false)
  tags                            = can(each.value.tags) ? merge(local.DefaultTags, each.value.tags) : local.DefaultTags

  dynamic "network_rules" {
    for_each = can(each.value.network_rules) ? [1] : []
    content {
      default_action = lookup(each.value.network_rules, "default_action", "Allow")
      bypass         = lookup(each.value.network_rules, "bypass", ["AzureServices"])
    }
  }
}