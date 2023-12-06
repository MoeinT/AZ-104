# module "ApplicationSecurityGroups" {
#   source = "../../CommonModules/ApplicationSecurityGroups"
#   properties = {
#     "app-asg-${var.env}" = {
#       location            = module.Rg.rg-locations["az-104-${var.env}"],
#       resource_group_name = module.Rg.rg-names["az-104-${var.env}"],
#     }
#   }
# }