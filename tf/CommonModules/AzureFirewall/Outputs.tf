output "firewall-publicip-id" {
  value = { for i, j in azurerm_firewall.AzureFireWall : j.name => j.ip_configuration.0.public_ip_address_id if length(j.ip_configuration) != 0 }
}

output "firewall-name" {
  value = { for i, j in azurerm_firewall.AzureFireWall : j.name => j.name }
}