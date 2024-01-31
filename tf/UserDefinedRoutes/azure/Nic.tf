# Create a NIC and associate it to the Public IP
module "NICs" {
  source = "../../CommonModules/NetworkInterface"
  properties = {
    # Nic VM
    "nicA-${var.env}" = {
      location            = module.Rg.rg-locations["az-104-${var.env}"],
      resource_group_name = module.Rg.rg-names["az-104-${var.env}"],
      ip_configuration = {
        name                          = "internal",
        subnet_id                     = module.Subnets.subnet-id["SubNetA-${var.env}"],
        private_ip_address_allocation = "Dynamic",
        public_ip_address_id = module.publicIPs.publicIp-id["publicip-VmA-${var.env}"]
      }
    },
    "nicB-${var.env}" = {
      location            = module.Rg.rg-locations["az-104-${var.env}"],
      resource_group_name = module.Rg.rg-names["az-104-${var.env}"],
      ip_configuration = {
        name                          = "internal",
        subnet_id                     = module.Subnets.subnet-id["SubNetB-${var.env}"],
        private_ip_address_allocation = "Dynamic",
        public_ip_address_id          = module.publicIPs.publicIp-id["publicip-VmB-${var.env}"]
      }
    },
    "nicCentral-${var.env}" = {
      location            = module.Rg.rg-locations["az-104-${var.env}"],
      resource_group_name = module.Rg.rg-names["az-104-${var.env}"],
      # Centralvm should be able to forward traffic to appvmB
      enable_ip_forwarding = true
      ip_configuration = {
        name                          = "internal",
        subnet_id                     = module.Subnets.subnet-id["SubnetCental-${var.env}"],
        private_ip_address_allocation = "Dynamic",
        public_ip_address_id          = module.publicIPs.publicIp-id["publicip-VmCentral-${var.env}"]
      }
    }
  }
}