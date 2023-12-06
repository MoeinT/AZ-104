output "lb-ids" {
  value = { for i, j in azurerm_lb.LBs : j.name => j.id }
}

output "lb-frontendname" {
  value = { for i, j in azurerm_lb.LBs : j.name => j.frontend_ip_configuration[0].name }
}