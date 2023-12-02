output "appsecuritygroup-id" {
  value = { for i, j in azurerm_application_security_group.ApplicationSecurityGroups : j.name => j.id }
}