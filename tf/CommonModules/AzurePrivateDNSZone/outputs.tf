output "privatezone-id" {
  value = { for i, j in azurerm_private_dns_zone.privateDNSZones : i => j.id }
}

output "privatezone-name" {
  value = { for i, j in azurerm_private_dns_zone.privateDNSZones : i => j.name }
}