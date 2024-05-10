output "private-ip-address" {
  value = { for i, j in azurerm_private_endpoint.PrivateEndpoints : j.name => j.private_service_connection.0.private_ip_address }
}
