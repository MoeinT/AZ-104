# To be used by the Network Watcher Flow Log
module "StorageAccount" {
  source = "../../CommonModules/StorageAccounts"
  properties = {
    "saserviceendpoint${var.env}" = {
      resource_group_name             = module.Rg.rg-names["az-104-${var.env}"],
      location                        = module.Rg.rg-locations["az-104-${var.env}"],
      allow_nested_items_to_be_public = false
      public_network_access_enabled   = true
      account_tier                    = "Standard",
      account_kind                    = "StorageV2"
      network_rules = {
        default_action             = "Deny"
        virtual_network_subnet_ids = [module.Subnets.subnet-id["subnet-az-104-${var.env}"]]
      }
    },
    "saprivateendpoint${var.env}" = {
      resource_group_name             = module.Rg.rg-names["az-104-${var.env}"],
      location                        = module.Rg.rg-locations["az-104-${var.env}"],
      allow_nested_items_to_be_public = false
      public_network_access_enabled   = true
      account_tier                    = "Standard",
      account_kind                    = "StorageV2"
      network_rules = {
        default_action             = "Deny"
        virtual_network_subnet_ids = null
      }
    }
  }
}
