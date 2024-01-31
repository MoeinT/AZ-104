# This public IP address allows connectivity from the internet
module "publicIPs" {
  source = "../../CommonModules/PublicIp"
  properties = {
    # To log into vmCentral and enable routing
    "publicip-VmCentral-${var.env}" = {
      location            = module.Rg.rg-locations["az-104-${var.env}"],
      resource_group_name = module.Rg.rg-names["az-104-${var.env}"],
      allocation_method   = "Static",
      sku                 = "Standard"
    },
    # To log into vmA and request access to vmB
    "publicip-VmA-${var.env}" = {
      location            = module.Rg.rg-locations["az-104-${var.env}"],
      resource_group_name = module.Rg.rg-names["az-104-${var.env}"],
      allocation_method   = "Static",
      sku                 = "Standard"
    },
    # To log into VM and install information internet services
    "publicip-VmB-${var.env}" = {
      location            = module.Rg.rg-locations["az-104-${var.env}"],
      resource_group_name = module.Rg.rg-names["az-104-${var.env}"],
      allocation_method   = "Static",
      sku                 = "Standard"
    }
  }
}