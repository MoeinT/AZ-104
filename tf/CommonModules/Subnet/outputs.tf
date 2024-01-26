output "subnet-id" {
  value = { for i, j in azurerm_subnet.SubNet : i => j.id }
}