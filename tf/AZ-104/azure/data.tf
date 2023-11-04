data "azurerm_client_config" "current" {
}

data "azurerm_subscription" "current" {
}

data "azurerm_ssh_public_key" "SshPublicKey" {
  name                = "SSHVM"
  resource_group_name = module.Rg.rg-names["az-104-${var.env}"]
}