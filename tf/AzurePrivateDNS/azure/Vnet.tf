# Define a Virtual Network
module "Vnets" {
  source = "../../CommonModules/Vnet"
  properties = {
    "Vnet-${var.env}" = {
      address_space       = ["10.0.0.0/16"]
      location            = module.Rg.rg-locations["az-104-${var.env}"]
      resource_group_name = module.Rg.rg-names["az-104-${var.env}"]
    }
  }
}

# Define a subnet within the Vnet
module "Subnets" {
  source = "../../CommonModules/Subnet"
  properties = {
    "subnetA-${var.env}" = {
      resource_group_name  = module.Rg.rg-names["az-104-${var.env}"],
      virtual_network_name = module.Vnets.vnet-name["Vnet-${var.env}"],
      address_prefixes     = ["10.0.0.0/24"]
    },
    "subnetB-${var.env}" = {
      resource_group_name  = module.Rg.rg-names["az-104-${var.env}"],
      virtual_network_name = module.Vnets.vnet-name["Vnet-${var.env}"],
      address_prefixes     = ["10.0.1.0/24"]
    }
  }
}

# Adding a NSG at the subnet level
module "NSGSubnetAttachment" {
  source = "../../CommonModules/NSGSubnetAssociation"
  properties = {
    "source-subnet-NSG-${var.env}" = {
      subnet_id                 = module.Subnets.subnet-id["subnetA-${var.env}"],
      network_security_group_id = module.NSGs.nsg-id["app-public-nsg-${var.env}"]
    },
    "target-subnet-NSG-${var.env}" = {
      subnet_id                 = module.Subnets.subnet-id["subnetB-${var.env}"],
      network_security_group_id = module.NSGs.nsg-id["app-public-nsg-${var.env}"]
    }
  }
}