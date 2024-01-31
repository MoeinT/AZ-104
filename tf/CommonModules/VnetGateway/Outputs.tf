output "vnet-gateway-id" {
  value = { for i, j in azurerm_virtual_network_gateway.vnetGateways : j.name => j.id }
}