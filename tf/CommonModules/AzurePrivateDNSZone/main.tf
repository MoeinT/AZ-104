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

resource "azurerm_private_dns_zone" "privateDNSZones" {
  for_each            = var.properties
  name                = lookup(each.value, "name", each.key)
  resource_group_name = each.value.resource_group_name

  dynamic "soa_record" {
    for_each = can(each.value.soa_record) ? [1] : []
    content {
      email        = each.value.soa_record.email
      expire_time  = lookup(each.value.soa_record, "expire_time", 2419200)
      minimum_ttl  = lookup(each.value.soa_record, "minimum_ttl", 10)
      refresh_time = lookup(each.value.soa_record, "refresh_time", 3600)
      retry_time   = lookup(each.value.soa_record, "retry_time", 300)
      ttl          = lookup(each.value.soa_record, "ttl", 3600)
    }
  }
}