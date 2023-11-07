output "kv-id" {
  value = { for i, j in azurerm_key_vault.AllKV : j.name => j.id }
}