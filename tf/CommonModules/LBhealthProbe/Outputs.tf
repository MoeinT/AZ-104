output "healthprobe-id" {
  value = { for i, j in azurerm_lb_probe.LBhealthProbe : j.name => j.id }
}