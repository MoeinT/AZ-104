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
    "SubNet-public-${var.env}" = {
      resource_group_name  = module.Rg.rg-names["az-104-${var.env}"],
      virtual_network_name = module.Vnets.vnet-name["Vnet-${var.env}"],
      address_prefixes     = ["10.0.0.0/24"],
      service_endpoints    = ["Microsoft.KeyVault"]
    }
  }
}

# Adding a NSG at the subnet level
module "NSGSubnetAttachment" {
  source = "../../CommonModules/NSGSubnetAssociation"
  properties = {
    "SubNet-NSG-${var.env}" = {
      subnet_id                 = module.Subnets.subnet-id["SubNet-public-${var.env}"],
      network_security_group_id = module.NSGs.nsg-id["nsg-subnet-${var.env}"]
    }
  }
}