resource "azurerm_virtual_network" "Vnet" {
  name                = "Vnetwork-${var.env}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.Rg.location
  resource_group_name = azurerm_resource_group.Rg.name
}

resource "azurerm_subnet" "SubNet" {
  name                 = "SubNet-${var.env}"
  resource_group_name  = azurerm_resource_group.Rg.name
  virtual_network_name = azurerm_virtual_network.Vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}