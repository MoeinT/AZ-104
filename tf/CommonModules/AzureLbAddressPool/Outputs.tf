output "LBAddressPool-id" {
  value = { for i, j in azurerm_lb_backend_address_pool.LBAddressPool : j.name => j.id }
}