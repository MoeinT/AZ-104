output "nic-id" {
  value = { for i, j in azurerm_network_interface.NetInterface : j.name => j.id }
}
