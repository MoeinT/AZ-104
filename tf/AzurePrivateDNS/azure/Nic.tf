# Create a NIC and associate it to the Public IP
module "NICs" {
  source = "../../CommonModules/NetworkInterface"
  properties = {
    # Nic VM
    "dnsserver-nic-${var.env}" = {
      location            = module.Rg.rg-locations["az-104-${var.env}"],
      resource_group_name = module.Rg.rg-names["az-104-${var.env}"],
      ip_configuration = {
        name                          = "internal",
        subnet_id                     = module.Subnets.subnet-id["subnetA-${var.env}"],
        private_ip_address_allocation = "Dynamic",
        public_ip_address_id          = module.publicIPs.publicIp-id["dnsserver-public-ip-${var.env}"]
      }
    },
    "webserver-nic-${var.env}" = {
      location            = module.Rg.rg-locations["az-104-${var.env}"],
      resource_group_name = module.Rg.rg-names["az-104-${var.env}"],
      ip_configuration = {
        name                          = "internal",
        subnet_id                     = module.Subnets.subnet-id["subnetB-${var.env}"],
        private_ip_address_allocation = "Dynamic",
        public_ip_address_id          = module.publicIPs.publicIp-id["webserver-public-ip-${var.env}"]
      }
    }
  }
}