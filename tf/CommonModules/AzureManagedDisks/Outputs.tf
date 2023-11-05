output "disk-id" {
  value = { for i, j in azurerm_managed_disk.disk : j.name => j.id }
}