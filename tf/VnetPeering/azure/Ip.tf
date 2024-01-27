# This public IP address allows connectivity from the internet
module "publicIPs" {
  source = "../../CommonModules/PublicIp"
  properties = {
    "publicip-vm-Vnet1-${var.env}" = {
      location            = module.Rg.rg-locations["az-104-${var.env}"],
      resource_group_name = module.Rg.rg-names["az-104-${var.env}"],
      allocation_method   = "Static",
      sku                 = "Standard"
    },
    "publicip-bastion-vnet1-${var.env}" = {
      location            = module.Rg.rg-locations["az-104-${var.env}"],
      resource_group_name = module.Rg.rg-names["az-104-${var.env}"],
      allocation_method   = "Static",
      sku                 = "Standard"
    }
  }
}