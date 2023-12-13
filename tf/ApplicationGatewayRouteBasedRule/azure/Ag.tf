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
          "images-backendpool-${var.env}" = {
          },
          "videos-backendpool-${var.env}" = {
          },
        }

      frontend_port = {
        "frontend-port-${var.env}" = {
          port = 80
        }
      }

        backend_http_settings = {
          "images-target-${var.env}" = {
            cookie_based_affinity = "Disabled"
            path                  = "/images/*"
            port                  = 80
            protocol              = "Http"
            request_timeout       = 60
          },
          "videos-target-${var.env}" = {
            cookie_based_affinity = "Disabled"
            path                  = "/videos/*"
            port                  = 80
            protocol              = "Http"
            request_timeout       = 60
          },
        },

        http_listener = {
          "http-listener-images-${var.env}" = {
            frontend_ip_configuration_name = "frontend-ip-${var.env}"
            frontend_port_name             = "frontend-port-${var.env}"
            protocol                       = "Http"
          },
          "http-listener-videos-${var.env}" = {
            frontend_ip_configuration_name = "frontend-ip-${var.env}"
            frontend_port_name             = "frontend-port-${var.env}"
            protocol                       = "Http"
          },
        }

      request_routing_rule = {
        "request-routing-rule-images-${var.env}" = {
          priority                   = 9
          rule_type                  = "PathBasedRouting"
          http_listener_name         = "http-listener-images-${var.env}"
          backend_address_pool_name  = "images-backendpool-${var.env}"
          backend_http_settings_name = "images-target-${var.env}"
        },
        "request-routing-rule-videos-${var.env}" = {
          priority                   = 10
          rule_type                  = "PathBasedRouting"
          http_listener_name         = "http-listener-videos-${var.env}"
          backend_address_pool_name  = "videos-backendpool-${var.env}"
          backend_http_settings_name = "videos-target-${var.env}"
        }
      }
    },
  }
}

module "NicAppgatewayAssociation" {
  source = "../../CommonModules/NicAppGatewayAssociation"
  properties = {
    "nic-appgateway-images-${var.env}" = {
      network_interface_id    = module.NICs.nic-id["nic-imagesvm-${var.env}"]
      ip_configuration_name   = "internal"
      backend_address_pool_id = module.ApplicationGateway.appgateway-backendpool-id["appgateway-${var.env}"]["images-backendpool-${var.env}"]
    },
    "nic-appgateway-videos-${var.env}" = {
      network_interface_id    = module.NICs.nic-id["nic-videosvm-${var.env}"]
      ip_configuration_name   = "internal"
      backend_address_pool_id = module.ApplicationGateway.appgateway-backendpool-id["appgateway-${var.env}"]["videos-backendpool-${var.env}"]
    }
  }
}