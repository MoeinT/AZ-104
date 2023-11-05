output "vm-id" {
  value = { for i, j in azurerm_linux_virtual_machine.AppLinuxVm : j.name => j.id }
}