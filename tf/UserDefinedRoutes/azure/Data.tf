data "azurerm_client_config" "current" {
}

data "azurerm_subscription" "current" {
}

# To return the private ip address of the central virtual network appliance
data "azurerm_virtual_machine" "CentralVm" {
  name                = "centralvm-${var.env}"
  resource_group_name = module.Rg.rg-names["az-104-${var.env}"]
}