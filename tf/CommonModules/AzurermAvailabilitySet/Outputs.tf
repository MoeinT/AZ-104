output "availability-set-id" {
  value = { for i, j in azurerm_availability_set.AllAvailabilitySets : j.name => j.id }
}