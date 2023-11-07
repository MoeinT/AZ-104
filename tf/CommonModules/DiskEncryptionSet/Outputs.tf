output "encyptionset-principal-id" {
  value = { for i, j in azurerm_disk_encryption_set.diskEncyptionSet : j.name => j.identity.0.principal_id if length(j.identity) != 0 }
}

output "encyptionset-id" {
  value = { for i, j in azurerm_disk_encryption_set.diskEncyptionSet : j.name => j.id }
}

