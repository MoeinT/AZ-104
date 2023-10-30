resource "azurerm_resource_group" "Rg" {
  name     = "az-104-${var.env}"
  location = "West Europe"
}