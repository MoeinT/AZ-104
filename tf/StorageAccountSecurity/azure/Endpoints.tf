module "PrivateEndpoints" {
  source = "../../CommonModules/AzurePrivateEndpoint"
  properties = {
    "SaPrivateEndPoint-${var.env}" = {
      location            = module.Rg.rg-locations["az-104-${var.env}"],
      resource_group_name = module.Rg.rg-names["az-104-${var.env}"],
      subnet_id           = module.Subnets.subnet-id["subnet-az-104-${var.env}"]

      private_service_connection = {
        name                           = "sa-privateendpointconnection"
        is_manual_connection           = false
        private_connection_resource_id = module.StorageAccount.sa-id["saprivateendpoint${var.env}"]
        subresource_names              = ["blob"]
      }

      private_dns_zone_group = {
        name                 = module.AzurePrivateDNSZone.privatezone-name["azureprivatezone-${var.env}"]
        private_dns_zone_ids = [module.AzurePrivateDNSZone.privatezone-id["azureprivatezone-${var.env}"]]
      }

    }
  }
}
