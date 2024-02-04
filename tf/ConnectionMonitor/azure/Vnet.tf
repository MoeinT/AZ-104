# Define a Virtual Network
module "Vnets" {
  source = "../../CommonModules/Vnet"
  properties = {
    "source-Vnet-${var.env}" = {
      address_space       = ["10.0.0.0/16"]
      location            = module.Rg.rg-locations["az-104-${var.env}"]
      resource_group_name = module.Rg.rg-names["az-104-${var.env}"]
    },
    "target-Vnet-${var.env}" = {
      address_space       = ["10.1.0.0/16"]
      location            = module.Rg.rg-locations["az-104-${var.env}"]
      resource_group_name = module.Rg.rg-names["az-104-${var.env}"]
    }
  }
}

# Define a subnet within the Vnet
module "Subnets" {
  source = "../../CommonModules/Subnet"
  properties = {
    "source-subnet-${var.env}" = {
      resource_group_name  = module.Rg.rg-names["az-104-${var.env}"],
      virtual_network_name = module.Vnets.vnet-name["source-Vnet-${var.env}"],
      address_prefixes     = ["10.0.0.0/24"]
    },
    "target-subnet-${var.env}" = {
      resource_group_name  = module.Rg.rg-names["az-104-${var.env}"],
      virtual_network_name = module.Vnets.vnet-name["target-Vnet-${var.env}"],
      address_prefixes     = ["10.1.0.0/24"]
    }
  }
}

# Adding a NSG at the subnet level
module "NSGSubnetAttachment" {
  source = "../../CommonModules/NSGSubnetAssociation"
  properties = {
    "source-subnet-NSG-${var.env}" = {
      subnet_id                 = module.Subnets.subnet-id["source-subnet-${var.env}"],
      network_security_group_id = module.NSGs.nsg-id["app-public-nsg-${var.env}"]
    },
    "target-subnet-NSG-${var.env}" = {
      subnet_id                 = module.Subnets.subnet-id["target-subnet-${var.env}"],
      network_security_group_id = module.NSGs.nsg-id["app-public-nsg-${var.env}"]
    }
  }
}

# Vnet Peeting 
module "VnetPeering" {
  source = "../../CommonModules/VnetPeering"
  properties = {
    "source-to-target-${var.env}" = {
      resource_group_name       = module.Rg.rg-names["az-104-${var.env}"],
      virtual_network_name      = module.Vnets.vnet-name["source-Vnet-${var.env}"],
      remote_virtual_network_id = module.Vnets.vnet-id["target-Vnet-${var.env}"],
    },
    "target-to-source-${var.env}" = {
      resource_group_name       = module.Rg.rg-names["az-104-${var.env}"],
      virtual_network_name      = module.Vnets.vnet-name["target-Vnet-${var.env}"],
      remote_virtual_network_id = module.Vnets.vnet-id["source-Vnet-${var.env}"],
    }
  }
}