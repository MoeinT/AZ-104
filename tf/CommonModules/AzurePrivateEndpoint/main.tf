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

resource "azurerm_private_endpoint" "PrivateEndpoints" {
  for_each            = var.properties
  name                = can(each.value.name) ? each.value.name : each.key
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  subnet_id           = each.value.subnet_id

  private_service_connection {
    name                           = each.value.private_service_connection.name
    is_manual_connection           = each.value.private_service_connection.is_manual_connection
    private_connection_resource_id = lookup(each.value.private_service_connection, "private_connection_resource_id", null)
    subresource_names              = lookup(each.value.private_service_connection, "subresource_names", null)
  }

  dynamic "private_dns_zone_group" {
    for_each = can(each.value.private_dns_zone_group) ? [1] : []
    content {
      name                 = each.value.private_dns_zone_group.name
      private_dns_zone_ids = each.value.private_dns_zone_group.private_dns_zone_ids
    }
  }
}
