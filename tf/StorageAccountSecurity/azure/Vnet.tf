# Define a Virtual Network
module "Vnets" {
  source = "../../CommonModules/Vnet"
  properties = {
    "vnet-az-104-${var.env}" = {
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
    "subnet-az-104-${var.env}" = {
      resource_group_name  = module.Rg.rg-names["az-104-${var.env}"],
      virtual_network_name = module.Vnets.vnet-name["vnet-az-104-${var.env}"],
      address_prefixes     = ["10.0.0.0/24"]
      service_endpoints    = ["Microsoft.Storage"]
    }
  }
}

# Adding a NSG at the subnet level
module "NSGSubnetAttachment" {
  source = "../../CommonModules/NSGSubnetAssociation"
  properties = {
    "source-subnet-NSG-${var.env}" = {
      subnet_id                 = module.Subnets.subnet-id["subnet-az-104-${var.env}"],
      network_security_group_id = module.NSGs.nsg-id["nsg-az-104-${var.env}"]
    }
  }
}
