output "vm-id" {
  value = { for i, j in azurerm_windows_virtual_machine.AppVm : j.name => j.id }
}