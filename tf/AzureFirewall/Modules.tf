module "azure" {
  source            = "./azure"
  env               = var.env
  vm_admin_username = var.vm_admin_username
  vm_admin_password = var.vm_admin_password
  source_addresses  = var.source_addresses
}