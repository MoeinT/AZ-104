# Define a windows Virtual Machine
module "WindowsVM" {
  source = "../../CommonModules/windowsVM"
  properties = {
    "source-vm-${var.env}" = {
      resource_group_name   = module.Rg.rg-names["az-104-${var.env}"],
      location              = module.Rg.rg-locations["az-104-${var.env}"],
      admin_username        = var.vm_admin_username,
      admin_password        = var.vm_admin_password,
      size                  = "Standard_D2s_v3"
      network_interface_ids = [module.NICs.nic-id["nic-vm-az-104-${var.env}"]]
      boot_diagnostics      = {}
    }
  }
}
