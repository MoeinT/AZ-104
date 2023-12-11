# Create a Load Balancer for the App VMs
module "LoadBalancers" {
  source = "../../CommonModules/AzureLB"
  properties = {
    "app-loadbalancer-${var.env}" = {
      location            = module.Rg.rg-locations["az-104-${var.env}"],
      resource_group_name = module.Rg.rg-names["az-104-${var.env}"],
      sku                 = "Basic"
      frontend_ip_configuration = {
        "FrontEndIp-${var.env}" = {
          public_ip_address_id = module.publicIPs.publicIp-id["public-ip-lb-${var.env}"]
        }
      }
    },
  }
}

# Create a backend pool for the Load Balancer 
module "LBBackendAddressPool" {
  source = "../../CommonModules/AzureLbAddressPool"
  properties = {
    "app-loadbalancer-backendaddpool-${var.env}" = {
      loadbalancer_id = module.LoadBalancers.lb-ids["app-loadbalancer-${var.env}"]
    }
  }
}

# Create a health proble for the LB to know if the VMs as part of the pool are up & running
module "LBhealthProbe" {
  source = "../../CommonModules/LBhealthProbe"
  properties = {
    "lb-running-proble-${var.env}" = {
      loadbalancer_id     = module.LoadBalancers.lb-ids["app-loadbalancer-${var.env}"]
      port                = 80,
      protocol            = "Tcp",
      interval_in_seconds = 5
    }
  }
}

# Load Balancing Rules to forward incoming requests on port 80 (frontend port) to port 80 of the backend VM scaleset
module "LBRules" {
  source = "../../CommonModules/LBRule"
  properties = {
    "lb-rule-${var.env}" = {
      loadbalancer_id                = module.LoadBalancers.lb-ids["app-loadbalancer-${var.env}"]
      protocol                       = "Tcp",
      frontend_port                  = "80"
      backend_port                   = "80"
      backend_address_pool_ids       = [module.LBBackendAddressPool.LBAddressPool-id["app-loadbalancer-backendaddpool-${var.env}"]]
      probe_id                       = module.LBhealthProbe.healthprobe-id["lb-running-proble-${var.env}"],
      frontend_ip_configuration_name = module.LoadBalancers.lb-frontendname["app-loadbalancer-${var.env}"]
    }
  }
}