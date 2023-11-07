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

resource "azurerm_key_vault_key" "kvKey" {
  for_each     = var.properties
  name         = each.key
  key_vault_id = each.value.key_vault_id
  key_type     = each.value.key_type
  key_opts     = each.value.key_opts
  key_size     = lookup(each.value, "key_size", 1024)

  # Optionally provide a rotation_policy
  dynamic "rotation_policy" {
    for_each = can(each.value.rotation_policy) ? [1] : []
    content {
      expire_after         = each.value.rotation_policy.expire_after
      notify_before_expiry = each.value.rotation_policy.notify_before_expiry
      # Optionally provide an automatic block inside rotation_policy
      dynamic "automatic" {
        for_each = can(each.value.rotation_policy.automatic) ? [1] : []
        content {
          time_before_expiry  = each.value.rotation_policy.automatic.time_before_expiry
          time_after_creation = each.value.rotation_policy.automatic.time_after_creation
        }
      }
    }
  }
}