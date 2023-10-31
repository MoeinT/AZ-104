output "publicIp-id" {
  value = { for i, j in azurerm_public_ip.PublicIP : j.name => j.id }
}

