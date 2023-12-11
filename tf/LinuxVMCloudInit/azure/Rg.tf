module "Rg" {
  source = "../../CommonModules/ResourceGroups"
  env    = var.env
  properties = {
    "az-104-${var.env}" = {
      location = "West Europe"
      tags     = { "Terraform_Developer" : "Moein" }
    }
  }
}