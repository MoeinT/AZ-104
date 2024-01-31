output "route-ids" {
  value = { for i, j in azurerm_route_table.RouteTable : j.name => j.id }
}