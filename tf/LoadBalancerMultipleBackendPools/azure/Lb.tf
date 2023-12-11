# Create a Load Balancer for the App VMs
module "LoadBalancers" {
  source = "../../CommonModules/AzureLB"
  properties = {
    "app-loadbalancer-${var.env}" = {
      location            = module.Rg.rg-locations["az-104-${var.env}"],
      resource_group_name = module.Rg.rg-names["az-104-${var.env}"],
      sku                 = "Standard"
      frontend_ip_configuration = {
        "FrontEndIp-windows-${var.env}" = {
          public_ip_address_id = module.publicIPs.publicIp-id["public-ip-lb-windows-${var.env}"]
        },
        "FrontEndIp-linux-${var.env}" = {
          public_ip_address_id = module.publicIPs.publicIp-id["public-ip-lb-linux-${var.env}"]
        }
      }
    },
  }
}

# Create a backend pool for the Load Balancer 
module "LBBackendAddressPool" {
  source = "../../CommonModules/AzureLbAddressPool"
  properties = {
    "lb-backendpool-windows-${var.env}" = {
      loadbalancer_id = module.LoadBalancers.lb-ids["app-loadbalancer-${var.env}"]
    },
    "lb-backendpool-linux-${var.env}" = {
      loadbalancer_id = module.LoadBalancers.lb-ids["app-loadbalancer-${var.env}"]
    }
  }
}

# Associate the backend pool to the Network Interface of the VMs
module "LBPoolNicAssociation" {
  source = "../../CommonModules/LBPoolNicAssociation"
  properties = {
    # Backend pool for Windows VMs
    "LbPool-Nic-windows-vm-1-${var.env}" = {
      network_interface_id    = module.NICs.nic-id["nic-windowsvm-1-${var.env}"]
      ip_configuration_name   = "internal"
      backend_address_pool_id = module.LBBackendAddressPool.LBAddressPool-id["lb-backendpool-windows-${var.env}"]
    },
    "LbPool-Nic-windows-vm-2-${var.env}" = {
      network_interface_id    = module.NICs.nic-id["nic-windowsvm-2-${var.env}"]
      ip_configuration_name   = "internal"
      backend_address_pool_id = module.LBBackendAddressPool.LBAddressPool-id["lb-backendpool-windows-${var.env}"]
    },
    # Backend pool for Linux VMs
    "LbPool-Nic-linux-vm-${var.env}" = {
      network_interface_id    = module.NICs.nic-id["nic-linuxvm-${var.env}"]
      ip_configuration_name   = "internal"
      backend_address_pool_id = module.LBBackendAddressPool.LBAddressPool-id["lb-backendpool-linux-${var.env}"]
    },
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

# Load Balancing Rules to forward incoming requests on port 80 (frontend port) to port 80 of the backend virtual machines (backend pool)
module "LBRules" {
  source = "../../CommonModules/LBRule"
  properties = {
    "lb-rule-windows-${var.env}" = {
      loadbalancer_id                = module.LoadBalancers.lb-ids["app-loadbalancer-${var.env}"]
      protocol                       = "Tcp",
      frontend_port                  = "80"
      backend_port                   = "80"
      backend_address_pool_ids       = [module.LBBackendAddressPool.LBAddressPool-id["lb-backendpool-windows-${var.env}"]]
      probe_id                       = module.LBhealthProbe.healthprobe-id["lb-running-proble-${var.env}"],
      frontend_ip_configuration_name = module.LoadBalancers.lb-frontendname["app-loadbalancer-${var.env}"]["FrontEndIp-windows-${var.env}"]
    },
    "lb-rule-linux-${var.env}" = {
      loadbalancer_id                = module.LoadBalancers.lb-ids["app-loadbalancer-${var.env}"]
      protocol                       = "Tcp",
      frontend_port                  = "80"
      backend_port                   = "80"
      backend_address_pool_ids       = [module.LBBackendAddressPool.LBAddressPool-id["lb-backendpool-linux-${var.env}"]]
      probe_id                       = module.LBhealthProbe.healthprobe-id["lb-running-proble-${var.env}"],
      frontend_ip_configuration_name = module.LoadBalancers.lb-frontendname["app-loadbalancer-${var.env}"]["FrontEndIp-linux-${var.env}"]
    }
  }
}

# Create a NAT rule for the above LB to log into the VMs at the backend
module "LBNatRule" {
  source = "../../CommonModules/LBNatRule"
  properties = {
    # "rdp-access-vm1-${var.env}" = {
    #   resource_group_name            = module.Rg.rg-names["az-104-${var.env}"],
    #   loadbalancer_id                = module.LoadBalancers.lb-ids["app-loadbalancer-${var.env}"]
    #   protocol                       = "Tcp"
    #   frontend_port                  = "4000"
    #   backend_port                   = "3389"
    #   frontend_ip_configuration_name = module.LoadBalancers.lb-frontendname["app-loadbalancer-${var.env}"]
    # },
    # "rdp-access-vm2-${var.env}" = {
    #   resource_group_name            = module.Rg.rg-names["az-104-${var.env}"],
    #   loadbalancer_id                = module.LoadBalancers.lb-ids["app-loadbalancer-${var.env}"]
    #   protocol                       = "Tcp"
    #   frontend_port                  = "4001"
    #   backend_port                   = "3389"
    #   frontend_ip_configuration_name = module.LoadBalancers.lb-frontendname["app-loadbalancer-${var.env}"]
    # }
  }
}