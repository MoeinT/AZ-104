output "networkwatcher-id" {
  value = { for i, j in azurerm_network_watcher.NetworkWatcher : j.name => j.id }
}

output "networkwatcher-name" {
  value = { for i, j in azurerm_network_watcher.NetworkWatcher : j.name => j.name }
}
