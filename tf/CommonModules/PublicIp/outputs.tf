output "publicIp-id" {
  value = { for i, j in azurerm_public_ip.PublicIP : j.name => j.id }
}

output "publicIp-address" {
  value = { for i, j in azurerm_public_ip.PublicIP : j.name => j.ip_address }
}