output "kvkey-id" {
  value = { for i, j in azurerm_key_vault_key.kvKey : j.name => j.id }
}