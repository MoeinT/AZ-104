output "lb-ids" {
  value = { for i, j in azurerm_lb.LBs : j.name => j.id }
}

output "lb-frontendname" {
  value = {
    for key, value in azurerm_lb.LBs : key => {
      for config in value.frontend_ip_configuration : config.name => config.name
    }
  }
}