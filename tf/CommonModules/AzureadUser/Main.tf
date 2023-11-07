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

resource "azuread_user" "User" {
  for_each             = var.properties
  display_name         = each.value.display_name
  user_principal_name  = each.value.user_principal_name
  password             = lookup(each.value, "password", null)
  other_mails          = lookup(each.value, "other_mails", null)
  usage_location       = lookup(each.value, "usage_location", null)
  mail_nickname        = lookup(each.value, "mail_nickname", null)
  show_in_address_list = lookup(each.value, "show_in_address_list", null)
}