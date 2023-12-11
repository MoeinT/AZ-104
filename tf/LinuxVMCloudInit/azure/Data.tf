data "azurerm_client_config" "current" {
}

data "azurerm_subscription" "current" {
}

data "template_file" "cloud_init_script" {
  template = file("cloudinit/linuxvm.yaml")
}

data "template_cloudinit_config" "cloud_config" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "cloud-init-script"
    content_type = "text/cloud-config"
    content      = data.template_file.cloud_init_script.rendered
  }
}