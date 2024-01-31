# Define a Virtual Network
module "Vnets" {
  source = "../../CommonModules/Vnet"
  properties = {
    "appNetwork-${var.env}" = {
      address_space       = ["10.0.0.0/16"]
      location            = module.Rg.rg-locations["az-104-${var.env}"]
      resource_group_name = module.Rg.rg-names["az-104-${var.env}"]
    }
  }
}

# Define 3 subnets within the above Virtual Network
module "Subnets" {
  source = "../../CommonModules/Subnet"
  properties = {
    "SubNetA-${var.env}" = {
      resource_group_name  = module.Rg.rg-names["az-104-${var.env}"],
      virtual_network_name = module.Vnets.vnet-name["appNetwork-${var.env}"],
      address_prefixes     = ["10.0.0.0/24"]
    },
    "SubNetB-${var.env}" = {
      resource_group_name  = module.Rg.rg-names["az-104-${var.env}"],
      virtual_network_name = module.Vnets.vnet-name["appNetwork-${var.env}"],
      address_prefixes     = ["10.0.1.0/24"]
    },
    "SubnetCental-${var.env}" = {
      resource_group_name  = module.Rg.rg-names["az-104-${var.env}"],
      virtual_network_name = module.Vnets.vnet-name["appNetwork-${var.env}"],
      address_prefixes     = ["10.0.2.0/24"]
    }
  }
}

# Allow RDP access to SubnetCentral
module "NSGSubnetAttachment" {
  source = "../../CommonModules/NSGSubnetAssociation"
  properties = {
    # And RDP access should be allowed for all the 3 Vms
    "SubNetCentral-Nsg-${var.env}" = {
      subnet_id                 = module.Subnets.subnet-id["SubnetCental-${var.env}"],
      network_security_group_id = module.NSGs.nsg-id["app-nsg-${var.env}"]
    },
    "SubNetA-Nsg-${var.env}" = {
      subnet_id                 = module.Subnets.subnet-id["SubNetA-${var.env}"],
      network_security_group_id = module.NSGs.nsg-id["app-nsg-${var.env}"]
    },
    "SubNetB-Nsg-${var.env}" = {
      subnet_id                 = module.Subnets.subnet-id["SubNetB-${var.env}"],
      network_security_group_id = module.NSGs.nsg-id["app-nsg-${var.env}"]
    },
  }
}