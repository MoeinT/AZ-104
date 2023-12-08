output "scaleset-id" {
  value = { for i, j in azurerm_windows_virtual_machine_scale_set.VMScaleSets : j.name => j.id }
}