# This public IP address allows connectivity from the internet
module "publicIPs" {
  source = "../../CommonModules/PublicIp"
  properties = {
    "firewall-public-ip-${var.env}" = {
      location            = module.Rg.rg-locations["az-104-${var.env}"],
      resource_group_name = module.Rg.rg-names["az-104-${var.env}"],
      allocation_method   = "Static",
      sku                 = "Standard"
    }
  }
}
#module.publicIPs.publicIp-id["firewall-public-ip-${var.env}"]