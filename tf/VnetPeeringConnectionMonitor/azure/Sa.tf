# To be used by the Network Watcher Flow Log
module "StorageAccount" {
  source = "../../CommonModules/StorageAccounts"
  properties = {
    "saflowlog${var.env}" = {
      resource_group_name = module.Rg.rg-names["az-104-${var.env}"],
      location            = module.Rg.rg-locations["az-104-${var.env}"],
      account_tier        = "Standard",
    }
  }
}