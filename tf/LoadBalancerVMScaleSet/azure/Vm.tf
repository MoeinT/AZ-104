# Create a VM Scale set along with a network interface and attach it to the Load Balancer Backend Pool
module "VMScaleSet" {
  source = "../../CommonModules/AzureVMWindowsScaleSet"
  properties = {
    "vm-scaleset-${var.env}" = {
      resource_group_name  = module.Rg.rg-names["az-104-${var.env}"],
      location             = module.Rg.rg-locations["az-104-${var.env}"],
      sku                  = "Standard_F2"
      instances            = 1
      admin_password       = var.vm_admin_password
      admin_username       = var.vm_admin_username
      computer_name_prefix = "appvm-${var.env}"
      network_interface = {
        name    = "app-vm-nic-${var.env}",
        primary = true,
        ip_configuration = {
          name                                   = "internal"
          primary                                = true
          subnet_id                              = module.Subnets.subnet-id["SubNet-public-${var.env}"],
          load_balancer_backend_address_pool_ids = [module.LBBackendAddressPool.LBAddressPool-id["app-loadbalancer-backendaddpool-${var.env}"]]
          public_ip_address = {
            name = "public-ip-scaleset-${var.env}"
          }
        }
      }
    }
  }
}