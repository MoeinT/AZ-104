output "appgateway-backendpool-id" {
  value = {
    for key, value in azurerm_application_gateway.network : key => {
      for config in value.backend_address_pool : config.name => config.id
    }
  }
}

output "appgateway-ipconfig-name" {
  value = {
    for key, value in azurerm_application_gateway.network : key => {
      for config in value.gateway_ip_configuration : config.name => config.name
    }
  }
}



