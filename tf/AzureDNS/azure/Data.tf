data "azurerm_client_config" "current" {
}

data "azurerm_subscription" "current" {
}

# To return the private ip address of the app vm
data "azurerm_virtual_machine" "web-vm" {
  name                = "web-vm-${var.env}"
  resource_group_name = module.Rg.rg-names["az-104-${var.env}"]
  depends_on          = [module.WindowsVM]
}

data "azurerm_virtual_machine" "client-vm" {
  name                = "client-vm-${var.env}"
  resource_group_name = module.Rg.rg-names["az-104-${var.env}"]
  depends_on          = [module.WindowsVM]
}