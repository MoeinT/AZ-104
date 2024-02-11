output "firewallpolicy-id" {
  value = { for i, j in azurerm_firewall_policy.FirewallPolicies : j.name => j.id }
}