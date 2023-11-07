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

resource "azurerm_disk_encryption_set" "diskEncyptionSet" {
  for_each            = var.properties
  name                = each.key
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  key_vault_key_id    = each.value.key_vault_key_id

  identity {
    type         = each.value.identity.type
    identity_ids = can(each.value.identity.identity_ids) ? each.value.identity.identity_ids : null
  }
}