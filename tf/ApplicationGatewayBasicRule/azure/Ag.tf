# module.publicIPs.publicIp-id["publicip-appgateway-${var.env}"]
module "ApplicationGateway" {
  source = "../../CommonModules/ApplicationGateway"
  properties = {
    "appgateway-${var.env}" = {
      location            = module.Rg.rg-locations["az-104-${var.env}"],
      resource_group_name = module.Rg.rg-names["az-104-${var.env}"],
      sku                 = "Standard_v2",
      tier                = "Standard_v2",
      capacity            = 2,

      gateway_ip_configuration = {
        "gateway-ip-configuration-${var.env}" = {
          subnet_id = module.Subnets.subnet-id["SubNet-appgateway-${var.env}"],
        },
      }

      frontend_ip_configuration = {
        "frontend-ip-${var.env}" = {
          public_ip_address_id = module.publicIPs.publicIp-id["publicip-appgateway-${var.env}"]
        },
      },

      backend_address_pool = {
        "windows-backendpool-${var.env}" = {
        },
        "linux-backendpool-${var.env}" = {
        },
      }

      frontend_port = {
        "frontend-port-windows-${var.env}" = {
          port = 80
        },
        "frontend-port-linux-${var.env}" = {
          port = 4000
        }
      }

      backend_http_settings = {
        "windows-target-${var.env}" = {
          cookie_based_affinity = "Disabled"
          port                  = 80
          protocol              = "Http"
          request_timeout       = 60
        },
        "linux-target-${var.env}" = {
          cookie_based_affinity = "Disabled"
          port                  = 80
          protocol              = "Http"
          request_timeout       = 60
        },
      },

      http_listener = {
        "http-listener-windows-${var.env}" = {
          frontend_ip_configuration_name = "frontend-ip-${var.env}"
          frontend_port_name             = "frontend-port-windows-${var.env}"
          protocol                       = "Http"
        },
        "http-listener-linux-${var.env}" = {
          frontend_ip_configuration_name = "frontend-ip-${var.env}"
          frontend_port_name             = "frontend-port-linux-${var.env}"
          protocol                       = "Http"
        },
      }

      request_routing_rule = {
        "request-routing-rule-windows-${var.env}" = {
          priority                   = 9
          rule_type                  = "Basic"
          http_listener_name         = "http-listener-windows-${var.env}"
          backend_address_pool_name  = "windows-backendpool-${var.env}"
          backend_http_settings_name = "windows-target-${var.env}"
        },
        "request-routing-rule-linux-${var.env}" = {
          priority                   = 10
          rule_type                  = "Basic"
          http_listener_name         = "http-listener-linux-${var.env}"
          backend_address_pool_name  = "linux-backendpool-${var.env}"
          backend_http_settings_name = "linux-target-${var.env}"
        }
      }
    },
  }
}

# Associate the above backend pool
module "NicAppgatewayAssociation" {
  source = "../../CommonModules/NicAppGatewayAssociation"
  properties = {
    "nic-appgateway-windows-${var.env}" = {
      network_interface_id    = module.NICs.nic-id["nic-windows-${var.env}"]
      ip_configuration_name   = "internal"
      backend_address_pool_id = module.ApplicationGateway.appgateway-backendpool-id["appgateway-${var.env}"]["windows-backendpool-${var.env}"]
    },
    "nic-appgateway-linux-${var.env}" = {
      network_interface_id    = module.NICs.nic-id["nic-linux-${var.env}"]
      ip_configuration_name   = "internal"
      backend_address_pool_id = module.ApplicationGateway.appgateway-backendpool-id["appgateway-${var.env}"]["linux-backendpool-${var.env}"]
    }
  }
}