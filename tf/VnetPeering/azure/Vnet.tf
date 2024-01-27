# Define a Virtual Network
module "Vnets" {
  source = "../../CommonModules/Vnet"
  properties = {
    "Vnet-1-${var.env}" = {
      address_space       = ["10.0.0.0/16"]
      location            = module.Rg.rg-locations["az-104-${var.env}"]
      resource_group_name = module.Rg.rg-names["az-104-${var.env}"]
    },
    "Vnet-2-${var.env}" = {
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
    "SubNet-vnet-1-${var.env}" = {
      resource_group_name  = module.Rg.rg-names["az-104-${var.env}"],
      virtual_network_name = module.Vnets.vnet-name["Vnet-1-${var.env}"],
      address_prefixes     = ["10.0.0.0/24"],
      service_endpoints    = ["Microsoft.KeyVault"]
    },
    "SubNet-vnet-2-${var.env}" = {
      resource_group_name  = module.Rg.rg-names["az-104-${var.env}"],
      virtual_network_name = module.Vnets.vnet-name["Vnet-2-${var.env}"],
      address_prefixes     = ["10.1.0.0/24"],
      service_endpoints    = ["Microsoft.KeyVault"]
    },
    "BastionSubnet-Vnet1-${var.env}" = {
      name                 = "AzureBastionSubnet"
      resource_group_name  = module.Rg.rg-names["az-104-${var.env}"],
      virtual_network_name = module.Vnets.vnet-name["Vnet-1-${var.env}"],
      address_prefixes     = ["10.0.1.0/24"],
      service_endpoints    = ["Microsoft.KeyVault"]
    }
  }
}

# Adding a NSG at the subnet level
module "NSGSubnetAttachment" {
  source = "../../CommonModules/NSGSubnetAssociation"
  properties = {
    "SubNet-vnet1-NSG-${var.env}" = {
      subnet_id                 = module.Subnets.subnet-id["SubNet-vnet-1-${var.env}"],
      network_security_group_id = module.NSGs.nsg-id["app-public-nsg-${var.env}"]
    },
    "SubNet-vnet2-NSG-${var.env}" = {
      subnet_id                 = module.Subnets.subnet-id["SubNet-vnet-2-${var.env}"],
      network_security_group_id = module.NSGs.nsg-id["app-public-nsg-${var.env}"]
    }
  }
}

# Vnet Peeting 
module "VnetPeering" {
  source = "../../CommonModules/VnetPeering"
  properties = {
    "vnet1-to-Vnet2-${var.env}" = {
      resource_group_name       = module.Rg.rg-names["az-104-${var.env}"],
      virtual_network_name      = module.Vnets.vnet-name["Vnet-2-${var.env}"],
      remote_virtual_network_id = module.Vnets.vnet-id["Vnet-1-${var.env}"],
    },
    "vnet2-to-Vnet1-${var.env}" = {
      resource_group_name       = module.Rg.rg-names["az-104-${var.env}"],
      virtual_network_name      = module.Vnets.vnet-name["Vnet-1-${var.env}"],
      remote_virtual_network_id = module.Vnets.vnet-id["Vnet-2-${var.env}"],
    }
  }
}