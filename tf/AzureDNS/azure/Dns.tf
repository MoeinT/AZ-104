# A private DNS Zone with a private domain name
module "AzurePrivateDNSZone" {
  source = "../../CommonModules/AzurePrivateDNSZone"
  properties = {
    "azureprivatezone-${var.env}" = {
      name                = "cloud2hub.com"
      resource_group_name = module.Rg.rg-names["az-104-${var.env}"]
    }
  }
}

# Linking the DNS to the Vnet
module "PrivateDNSVnetLink" {
  source = "../../CommonModules/PrivateDNSVnetLink"
  properties = {
    "cloud2hub-web-vnet-link-${var.env}" = {
      resource_group_name   = module.Rg.rg-names["az-104-${var.env}"]
      private_dns_zone_name = module.AzurePrivateDNSZone.privatezone-name["azureprivatezone-${var.env}"]
      virtual_network_id    = module.Vnets.vnet-id["web-Vnet-${var.env}"]
      registration_enabled  = true
    },
    "cloud2hub-client-vnet-link-${var.env}" = {
      resource_group_name   = module.Rg.rg-names["az-104-${var.env}"]
      private_dns_zone_name = module.AzurePrivateDNSZone.privatezone-name["azureprivatezone-${var.env}"]
      virtual_network_id    = module.Vnets.vnet-id["client-Vnet-${var.env}"]
      registration_enabled  = false
    }
  }
}

# Creating an "A" record to have "cloud2hub.com" as the domain name for the web server
module "PrivatDNSARecord" {
  source = "../../CommonModules/AzureDnsARecord"
  properties = {
    "web-server-A-record-${var.env}" = {
      name                = "@"
      zone_name           = module.AzurePrivateDNSZone.privatezone-name["azureprivatezone-${var.env}"]
      resource_group_name = module.Rg.rg-names["az-104-${var.env}"]
      ttl                 = 1
      records             = [data.azurerm_virtual_machine.web-vm.private_ip_address]
    }
  }
}