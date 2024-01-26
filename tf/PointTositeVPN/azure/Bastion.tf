module "BastionHosts" {
  source = "../../CommonModules/AzureBastionHost"
  properties = {
    # "app-bastion-vnet1-${var.env}" = {
    #   location            = module.Rg.rg-locations["az-104-${var.env}"],
    #   resource_group_name = module.Rg.rg-names["az-104-${var.env}"],
    #   ip_configuration = {
    #     name                 = "app-bastion-ip-config-${var.env}"
    #     subnet_id            = module.Subnets.subnet-id["BastionSubnet-Vnet1-${var.env}"]
    #     public_ip_address_id = module.publicIPs.publicIp-id["publicip-bastion-vnet1-${var.env}"]
    #   }
    # }
  }
}