# Create a NIC and associate it to the Public IP
module "NICs" {
  source = "../../CommonModules/NetworkInterface"
  properties = {
    # Nic VM
    "client-nic-${var.env}" = {
      location            = module.Rg.rg-locations["az-104-${var.env}"],
      resource_group_name = module.Rg.rg-names["az-104-${var.env}"],
      ip_configuration = {
        name                          = "internal",
        subnet_id                     = module.Subnets.subnet-id["clientSubnet-${var.env}"],
        private_ip_address_allocation = "Dynamic",
        public_ip_address_id          = module.publicIPs.publicIp-id["client-public-ip-${var.env}"]
      }
    },
    "web-nic-${var.env}" = {
      location            = module.Rg.rg-locations["az-104-${var.env}"],
      resource_group_name = module.Rg.rg-names["az-104-${var.env}"],
      ip_configuration = {
        name                          = "internal",
        subnet_id                     = module.Subnets.subnet-id["webSubnet-${var.env}"],
        private_ip_address_allocation = "Dynamic",
        public_ip_address_id          = module.publicIPs.publicIp-id["web-public-ip-${var.env}"]
      }
    }
  }
}