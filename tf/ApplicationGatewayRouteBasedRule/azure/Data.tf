data "azurerm_client_config" "current" {
}

data "azurerm_subscription" "current" {
}

# Linux initial script
data "template_file" "cloud_init_script_linux" {
  template = file("cloudinit/linuxvm.yaml")
}

data "template_cloudinit_config" "cloud_config_linux" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "cloud-init-script"
    content_type = "text/cloud-config"
    content      = data.template_file.cloud_init_script_linux.rendered
  }
}

# data "azurerm_ssh_public_key" "sshkey" {
#   name                = "sshkey"
#   resource_group_name = module.Rg.rg-names["az-104-${var.env}"]
# }