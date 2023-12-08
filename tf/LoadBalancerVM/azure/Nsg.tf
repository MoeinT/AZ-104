# Security Group for the VM Network Interface
module "NSGs" {
  source = "../../CommonModules/NetworkSecurityGroup"
  properties = {
    "app-public-nsg-${var.env}" = {
      location            = module.Rg.rg-locations["az-104-${var.env}"]
      resource_group_name = module.Rg.rg-names["az-104-${var.env}"]
    }
  }
}

# Network secutiry rules
module "NetworkSecurityRules" {
  source = "../../CommonModules/NetworkSecurityRule"
  properties = {
    # Allowing internet to access SSH (port 22)
    "rdp-public-${var.env}" = {
      priority                    = 300
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "Tcp"
      source_port_range           = "*"
      destination_port_range      = "3389"
      source_address_prefix       = "*"
      destination_address_prefix  = "*"
      resource_group_name         = module.Rg.rg-names["az-104-${var.env}"]
      network_security_group_name = module.NSGs.nsg-name["app-public-nsg-${var.env}"]
    },
    # Allow inbound traffic through port 80
    "AllowHTTP" = {
      priority                    = 600
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "*"
      source_port_range           = "*"
      destination_port_range      = "80"
      source_address_prefix       = "*"
      destination_address_prefix  = "*"
      resource_group_name         = module.Rg.rg-names["az-104-${var.env}"]
      network_security_group_name = module.NSGs.nsg-name["app-public-nsg-${var.env}"]
    }
  }
}