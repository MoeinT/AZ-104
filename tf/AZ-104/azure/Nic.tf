# This public IP address allows connectivity from the internet
module "publicIPs" {
  source = "../../CommonModules/PublicIp"
  properties = {
    "public-ip-${var.env}" = {
      location            = module.Rg.rg-locations["az-104-${var.env}"],
      resource_group_name = module.Rg.rg-names["az-104-${var.env}"],
      allocation_method   = "Static",
      sku                 = "Basic"
    }
  }
}

# Create a NIC and associate it to the Public IP
module "NICs" {
  source = "../../CommonModules/NetworkInterface"
  properties = {
    # Nic VM
    "nic-vm-public-${var.env}" = {
      location            = module.Rg.rg-locations["az-104-${var.env}"],
      resource_group_name = module.Rg.rg-names["az-104-${var.env}"],
      ip_configuration = {
        name                          = "internal",
        subnet_id                     = module.Subnets.subnet-id["SubNet-public-${var.env}"],
        private_ip_address_allocation = "Dynamic",
        public_ip_address_id          = module.publicIPs.publicIp-id["public-ip-${var.env}"]
      }
    },
    # # Nic VM SSH
    "nic-vm-private-${var.env}" = {
      location            = module.Rg.rg-locations["az-104-${var.env}"],
      resource_group_name = module.Rg.rg-names["az-104-${var.env}"],
      ip_configuration = {
        name                          = "internal",
        subnet_id                     = module.Subnets.subnet-id["SubNet-private-${var.env}"],
        private_ip_address_allocation = "Dynamic"
      }
    }
  }
}

# Associate the security group to the network interface
module "NIC_NSG" {
  source = "../../CommonModules/NICNSGAssociation"
  properties = {
    "nic-nsg-private-${var.env}" = {
      network_interface_id      = module.NICs.nic-id["nic-vm-private-${var.env}"],
      network_security_group_id = module.NSGs.nsg-id["app-private-nsg-${var.env}"]
    },
    "nic-nsg-public-${var.env}" = {
      network_interface_id      = module.NICs.nic-id["nic-vm-public-${var.env}"],
      network_security_group_id = module.NSGs.nsg-id["app-public-nsg-${var.env}"]
    },
  }
}

# Associate an asg to a network interface
module "NicAsgAssociation" {
  source = "../../CommonModules/NicAsgAssociation"
  properties = {
    "nic-asg-private-association" = {
      network_interface_id          = module.NICs.nic-id["nic-vm-public-${var.env}"]
      application_security_group_id = module.ApplicationSecurityGroups.appsecuritygroup-id["app-asg-${var.env}"]
    }
  }
}