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
        (local.frontend_ip_configuration_name) = {
          public_ip_address_id = module.publicIPs.publicIp-id["publicip-appgateway-${var.env}"]
        },
      },

      # Two backend pools for the 'images' & 'videos' VMs
      backend_address_pool = {
        (local.backend_address_pool_name_images) = {
        },
        (local.backend_address_pool_name_videos) = {
        },
      }

      # A frontend port for incoming requests
      frontend_port = {
        (local.frontend_port_name) = {
          port = 80
        }
      }

      # Listeners accept traffic arriving on a specified combination of protocol, port, host, and IP address.
      http_listener = {
        (local.listener_name) = {
          frontend_ip_configuration_name = local.frontend_ip_configuration_name
          frontend_port_name             = local.frontend_port_name
          protocol                       = "Http"
        }
      }

      backend_http_settings = {
        (local.http_setting_name_images) = {
          cookie_based_affinity = "Disabled"
          port                  = 80
          protocol              = "Http"
          request_timeout       = 60
        },
        (local.http_setting_name_videos) = {
          cookie_based_affinity = "Disabled"
          port                  = 80
          protocol              = "Http"
          request_timeout       = 60
        },
      }

      request_routing_rule = {
        (local.request_routing_rule) = {
          priority           = 9
          rule_type          = "PathBasedRouting"
          http_listener_name = local.listener_name
          url_path_map_name  = local.url_path_map_name
        }
      }

      url_path_map = {
        name                                = local.url_path_map_name
        default_redirect_configuration_name = local.redirect_configuration_name
        path_rules = {
          "images-rule" = {
            paths                      = ["/images/*"]
            backend_address_pool_name  = local.backend_address_pool_name_images
            backend_http_settings_name = local.http_setting_name_images
          },
          "videos-rule" = {
            paths                      = ["/videos/*"]
            backend_address_pool_name  = local.backend_address_pool_name_videos
            backend_http_settings_name = local.http_setting_name_videos
          }
        }
      }

      # Default address when non of the specified paths are matched
      redirect_configuration = {
        (local.redirect_configuration_name) = {
          redirect_type = "Permanent"
          target_url = "https://stacksimplify.com/azure-aks/azure-kubernetes-service-introduction/"
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