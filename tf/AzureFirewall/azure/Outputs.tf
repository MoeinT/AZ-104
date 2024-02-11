output "obj-id" {
  value = data.azurerm_client_config.current.object_id
}

output "firewall-publicip-id" {
  value = module.Firewalls.firewall-publicip-id["app-firewall-${var.env}"]
}