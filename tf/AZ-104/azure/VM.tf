# Define a Linux Virtual Machine 
module "LinuxVM" {
  source = "../../CommonModules/LinuxVM"
  properties = {
    # using password for authentication
    "appvm-linux-${var.env}" = {
      resource_group_name   = module.Rg.rg-names["az-104-${var.env}"],
      location              = module.Rg.rg-locations["az-104-${var.env}"],
      size                  = var.vm_size
      admin_username        = var.vm_admin_username
      admin_password        = var.vm_admin_password
      network_interface_ids = [module.NICs.nic-id["nic-vm-${var.env}"]]
    },
    # Using SSH Keys for authentication
    # "appvm-linux-sshkey-${var.env}" = {
    #   resource_group_name   = module.Rg.rg-names["az-104-${var.env}"],
    #   location              = module.Rg.rg-locations["az-104-${var.env}"],
    #   size                  = var.vm_size,
    #   admin_username        = var.vm_admin_username,
    #   network_interface_ids = [module.NICs.nic-id["nic-vm-ssh-${var.env}"]],
    #   admin_ssh_key = {
    #     username   = var.vm_admin_username
    #     public_key = data.azurerm_ssh_public_key.SshPublicKey.public_key
    #   }
    # }
  }
}