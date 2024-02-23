# Define a Virtual Network
module "Vnets" {
  source = "../../CommonModules/Vnet"
  properties = {
    # The Vnet where the web-vm hosted
    "web-Vnet-${var.env}" = {
      address_space       = ["10.0.0.0/16"]
      location            = module.Rg.rg-locations["az-104-${var.env}"]
      resource_group_name = module.Rg.rg-names["az-104-${var.env}"]
    },
    # The Vnet where the app-vm is hosted
    "client-Vnet-${var.env}" = {
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
    "clientSubnet-${var.env}" = {
      resource_group_name  = module.Rg.rg-names["az-104-${var.env}"],
      virtual_network_name = module.Vnets.vnet-name["client-Vnet-${var.env}"],
      address_prefixes     = ["10.1.0.0/24"]
    },
    "webSubnet-${var.env}" = {
      resource_group_name  = module.Rg.rg-names["az-104-${var.env}"],
      virtual_network_name = module.Vnets.vnet-name["web-Vnet-${var.env}"],
      address_prefixes     = ["10.0.0.0/24"]
    }
  }
}

# Adding a NSG at the subnet level
module "NSGSubnetAttachment" {
  source = "../../CommonModules/NSGSubnetAssociation"
  properties = {
    "client-subnet-NSG-${var.env}" = {
      subnet_id                 = module.Subnets.subnet-id["clientSubnet-${var.env}"],
      network_security_group_id = module.NSGs.nsg-id["app-public-nsg-${var.env}"]
    },
    "web-subnet-NSG-${var.env}" = {
      subnet_id                 = module.Subnets.subnet-id["webSubnet-${var.env}"],
      network_security_group_id = module.NSGs.nsg-id["app-public-nsg-${var.env}"]
    }
  }
}

# Vnet Peeting between the client and the web Vnet
module "VnetPeering" {
  source = "../../CommonModules/VnetPeering"
  properties = {
    "target-to-source-${var.env}" = {
      resource_group_name       = module.Rg.rg-names["az-104-${var.env}"],
      virtual_network_name      = module.Vnets.vnet-name["web-Vnet-${var.env}"],
      remote_virtual_network_id = module.Vnets.vnet-id["client-Vnet-${var.env}"],
    },
    "source-to-target-${var.env}" = {
      resource_group_name       = module.Rg.rg-names["az-104-${var.env}"],
      virtual_network_name      = module.Vnets.vnet-name["client-Vnet-${var.env}"],
      remote_virtual_network_id = module.Vnets.vnet-id["web-Vnet-${var.env}"],
    }
  }
}