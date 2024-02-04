# Create a NIC and associate it to the Public IP
module "NICs" {
  source = "../../CommonModules/NetworkInterface"
  properties = {
    # Nic VM
    "source-vm-nic-${var.env}" = {
      location            = module.Rg.rg-locations["az-104-${var.env}"],
      resource_group_name = module.Rg.rg-names["az-104-${var.env}"],
      ip_configuration = {
        name                          = "internal",
        subnet_id                     = module.Subnets.subnet-id["source-subnet-${var.env}"],
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = module.publicIPs.publicIp-id["publicip-source-vm-${var.env}"]
      }
    },
    "target-vm-nic-${var.env}" = {
      location            = module.Rg.rg-locations["az-104-${var.env}"],
      resource_group_name = module.Rg.rg-names["az-104-${var.env}"],
      ip_configuration = {
        name                          = "internal",
        subnet_id                     = module.Subnets.subnet-id["target-subnet-${var.env}"],
        private_ip_address_allocation = "Dynamic",
        public_ip_address_id          = module.publicIPs.publicIp-id["publicip-target-vm-${var.env}"]
      }
    }
  }
}

# Associate the security group to the network interface
module "NIC_NSG" {
  source = "../../CommonModules/NICNSGAssociation"
  properties = {
    # "nic-nsg-public-2-${var.env}" = {
    #   network_interface_id      = module.NICs.nic-id["nic-vm-public-2-${var.env}"],
    #   network_security_group_id = module.NSGs.nsg-id["app-public-nsg-${var.env}"]
    # },
    # "nic-nsg-public-1-${var.env}" = {
    #   network_interface_id      = module.NICs.nic-id["nic-vm-public-1-${var.env}"],
    #   network_security_group_id = module.NSGs.nsg-id["app-public-nsg-${var.env}"]
    # },
  }
}

# Associate an asg to a network interface
module "NicAsgAssociation" {
  source = "../../CommonModules/NicAsgAssociation"
  properties = {
    # "nic-asg-private-association" = {
    #   network_interface_id          = module.NICs.nic-id["nic-vm-public-${var.env}"]
    #   application_security_group_id = module.ApplicationSecurityGroups.appsecuritygroup-id["app-asg-${var.env}"]
    # }
  }
}