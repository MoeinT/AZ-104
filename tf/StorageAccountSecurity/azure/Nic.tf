# Create a NIC and associate it to the Public IP
module "NICs" {
  source = "../../CommonModules/NetworkInterface"
  properties = {
    # Nic VM
    "nic-vm-az-104-${var.env}" = {
      location            = module.Rg.rg-locations["az-104-${var.env}"],
      resource_group_name = module.Rg.rg-names["az-104-${var.env}"],
      ip_configuration = {
        name                          = "internal",
        subnet_id                     = module.Subnets.subnet-id["subnet-az-104-${var.env}"],
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = module.publicIPs.publicIp-id["publicip-vm-az-104-${var.env}"]
      }
    }
  }
}
