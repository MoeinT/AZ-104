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

resource "azurerm_subnet_route_table_association" "RouteSubnetAssociation" {
  for_each       = var.properties
  subnet_id      = each.value.subnet_id
  route_table_id = each.value.route_table_id
}