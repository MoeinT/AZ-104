# This public IP address allows connectivity from the internet
module "publicIPs" {
  source = "../../CommonModules/PublicIp"
  properties = {
    "public-ip-${var.env}" = {
      location            = module.Rg.rg-locations["az-104-${var.env}"],
      resource_group_name = module.Rg.rg-names["az-104-${var.env}"],
      allocation_method   = "Static",
      sku                 = "Basic"
    },
    "public-ip-ssh-${var.env}" = {
      location            = module.Rg.rg-locations["az-104-${var.env}"],
      resource_group_name = module.Rg.rg-names["az-104-${var.env}"],
      allocation_method   = "Static",
      sku                 = "Basic"
    }
  }
}

# Security Group for the VM Network Interface
module "NSGs" {
  source = "../../CommonModules/NetworkSecurityGroup"
  properties = {
    "NSG-${var.env}" = {
      location            = module.Rg.rg-locations["az-104-${var.env}"]
      resource_group_name = module.Rg.rg-names["az-104-${var.env}"]
    }
  }
}

# Create a NIC and associate it to the Public IP
module "NICs" {
  source = "../../CommonModules/NetworkInterface"
  properties = {
    # Nic VM
    "nic-vm-${var.env}" = {
      location            = module.Rg.rg-locations["az-104-${var.env}"],
      resource_group_name = module.Rg.rg-names["az-104-${var.env}"],
      ip_configuration = {
        name                          = "internal",
        subnet_id                     = module.Subnets.subnet-id["SubNet-${var.env}"],
        private_ip_address_allocation = "Dynamic",
        public_ip_address_id          = module.publicIPs.publicIp-id["public-ip-${var.env}"]
      }
    },
    # Nic VM SSH
    "nic-vm-ssh-${var.env}" = {
      location            = module.Rg.rg-locations["az-104-${var.env}"],
      resource_group_name = module.Rg.rg-names["az-104-${var.env}"],
      ip_configuration = {
        name                          = "internal",
        subnet_id                     = module.Subnets.subnet-id["SubNet-${var.env}"],
        private_ip_address_allocation = "Dynamic",
        public_ip_address_id          = module.publicIPs.publicIp-id["public-ip-ssh-${var.env}"]
      }
    }
  }
}

# Associate the security group to the network interface
module "NIC_NSG" {
  source = "../../CommonModules/NetworkInterfaceSecurityGroupAssociation"
  properties = {
    "NIC_VM_NSG_${var.env}" = {
      network_interface_id      = module.NICs.nic-id["nic-vm-${var.env}"],
      network_security_group_id = module.NSGs.nsg-id["NSG-${var.env}"]
    },
    "NIC_VM_SSH_NSG_${var.env}" = {
      network_interface_id      = module.NICs.nic-id["nic-vm-ssh-${var.env}"],
      network_security_group_id = module.NSGs.nsg-id["NSG-${var.env}"]
    }
  }
}

# Network secutiry rules
module "NetworkSecurityRules" {
  source = "../../CommonModules/NetworkSecurityRule"
  properties = {
    # Allowing internet to access HTTP (port 80)
    "httpaccess${var.env}" = {
      priority                    = 300
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "Tcp"
      source_port_range           = "*"
      destination_port_range      = "80"
      source_address_prefix       = "*"
      destination_address_prefix  = "*"
      resource_group_name         = module.Rg.rg-names["az-104-${var.env}"]
      network_security_group_name = module.NSGs.nsg-name["NSG-${var.env}"]
    },
    # Allowing internet to access SSH (port 22)
    "sshaccess${var.env}" = {
      priority                    = 100
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "Tcp"
      source_port_range           = "*"
      destination_port_range      = "22"
      source_address_prefix       = "*"
      destination_address_prefix  = "*"
      resource_group_name         = module.Rg.rg-names["az-104-${var.env}"]
      network_security_group_name = module.NSGs.nsg-name["NSG-${var.env}"]
    }
  }
}