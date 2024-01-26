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
    "SubNet-appvm-${var.env}" = {
      resource_group_name  = module.Rg.rg-names["az-104-${var.env}"],
      virtual_network_name = module.Vnets.vnet-name["Vnet-${var.env}"],
      address_prefixes     = ["10.0.0.0/24"],
      service_endpoints    = ["Microsoft.KeyVault"]
    },
    "GatewaySubnet-${var.env}" = {
      name                 = "GatewaySubnet"
      resource_group_name  = module.Rg.rg-names["az-104-${var.env}"],
      virtual_network_name = module.Vnets.vnet-name["Vnet-${var.env}"],
      address_prefixes     = ["10.0.1.0/26"],
      service_endpoints    = ["Microsoft.KeyVault"]
    }
  }
}

# Adding a NSG at the subnet level
module "NSGSubnetAttachment" {
  source = "../../CommonModules/NSGSubnetAssociation"
  properties = {
    "SubNet-vnet1-NSG-${var.env}" = {
      subnet_id                 = module.Subnets.subnet-id["SubNet-appvm-${var.env}"],
      network_security_group_id = module.NSGs.nsg-id["app-public-nsg-${var.env}"]
    }
  }
}

# Virtual Network Gateway to establish a point-to-size VPN connection 
module "VnetGateway" {
  source = "../../CommonModules/VnetGateway"
  properties = {
    "Vnet-gateway-${var.env}" = {
      location            = module.Rg.rg-locations["az-104-${var.env}"],
      resource_group_name = module.Rg.rg-names["az-104-${var.env}"],
      sku                 = "Basic",
      type                = "Vpn",
      vpn_type            = "RouteBased",
      active_active       = false,
      enable_bgp          = false,
      ip_configuration = {
        "ip_configuration-${var.env}" = {
          public_ip_address_id = module.publicIPs.publicIp-id["Vnet-gateway-ip-${var.env}"],
          subnet_id            = module.Subnets.subnet-id["GatewaySubnet-${var.env}"],
        }
      }
    }
  }
}