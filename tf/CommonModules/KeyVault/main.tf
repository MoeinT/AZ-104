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

data "azurerm_client_config" "current" {}


resource "azurerm_key_vault" "AllKV" {
  for_each                    = var.properties
  name                        = each.key
  location                    = each.value.location
  resource_group_name         = each.value.resource_group_name
  enabled_for_disk_encryption = lookup(each.value, "enabled_for_disk_encryption", true)
  purge_protection_enabled    = lookup(each.value, "purge_protection_enabled", true)
  soft_delete_retention_days  = lookup(each.value, "soft_delete_retention_days", 7)
  tenant_id                   = each.value.tenant_id
  sku_name                    = each.value.sku_name
  tags                        = can(each.value.tags) ? merge(local.DefaultTags, each.value.tags) : local.DefaultTags

  dynamic "network_acls" {
    for_each = can(each.value.network_acls) ? [1] : [0]
    content {
      bypass                     = each.value.network_acls.bypass
      default_action             = each.value.network_acls.default_action
      ip_rules                   = can(each.value.network_acls.ip_rules) ? each.value.network_acls.ip_rules : null
      virtual_network_subnet_ids = can(each.value.network_acls.virtual_network_subnet_ids) ? each.value.network_acls.virtual_network_subnet_ids : null
    }
  }
}