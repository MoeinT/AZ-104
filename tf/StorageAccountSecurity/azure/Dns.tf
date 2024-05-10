# A private DNS Zone with a private domain name
module "AzurePrivateDNSZone" {
  source = "../../CommonModules/AzurePrivateDNSZone"
  properties = {
    "azureprivatezone-${var.env}" = {
      name                = "privatelink.blob.core.windows.net"
      resource_group_name = module.Rg.rg-names["az-104-${var.env}"]
    }
  }
}

# Linking the DNS to the Vnet
module "PrivateDNSVnetLink" {
  source = "../../CommonModules/PrivateDNSVnetLink"
  properties = {
    "azureprivatezone-vnet-link-${var.env}" = {
      resource_group_name   = module.Rg.rg-names["az-104-${var.env}"],
      private_dns_zone_name = module.AzurePrivateDNSZone.privatezone-name["azureprivatezone-${var.env}"]
      virtual_network_id    = module.Vnets.vnet-id["vnet-az-104-${var.env}"],
      registration_enabled  = true
    },
  }
}

module "PrivatDNSARecord" {
  source = "../../CommonModules/AzureDnsARecord"
  properties = {
    "sta-a-record_${var.env}" = {
      name                = "sta_a_record"
      zone_name           = module.AzurePrivateDNSZone.privatezone-name["azureprivatezone-${var.env}"]
      resource_group_name = module.Rg.rg-names["az-104-${var.env}"]
      ttl                 = 300
      records             = [module.PrivateEndpoints.private-ip-address["SaPrivateEndPoint-${var.env}"]]
    }
  }
}
