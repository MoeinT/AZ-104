output "vnet-name" {
  value = { for i, j in azurerm_virtual_network.Vnet : j.name => j.name }
}

output "vnet-id" {
  value = { for i, j in azurerm_virtual_network.Vnet : j.name => j.id }
}