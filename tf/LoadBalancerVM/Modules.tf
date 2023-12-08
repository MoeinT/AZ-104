module "azure" {
  source            = "./azure"
  env               = var.env
  vm_admin_username = var.vm_admin_username
  vm_admin_password = var.vm_admin_password
  vm_size           = var.vm_size
  azuread_password  = var.azuread_password
  ip_address        = var.ip_address
  vm_private_ip     = var.vm_private_ip
}