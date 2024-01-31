# Create a route table and specify the next target hop
module "RouteTable" {
  source = "../../CommonModules/AzureRouteTable"
  properties = {
    "custom-route-${var.env}" = {
      location                      = module.Rg.rg-locations["az-104-${var.env}"],
      resource_group_name           = module.Rg.rg-names["az-104-${var.env}"],
      disable_bgp_route_propagation = false
      route = {
        "route-${var.env}" = {
          # All traffic in the Vnet
          address_prefix = "10.0.0.0/16",
          # The traffic should be forwarded to the central VM, hence a virtual appliance
          next_hop_type = "VirtualAppliance",
          # The private Ip address of the central VM
          next_hop_in_ip_address = data.azurerm_virtual_machine.CentralVm.private_ip_address
        },
      },
    },
  }
}

# Associate the above route to the central subnet
module "RouteSubnetAssociation" {
  source = "../../CommonModules/RouteSubnetAssociation"
  properties = {
    "SubnetARoute-${var.env}" = {
      subnet_id      = module.Subnets.subnet-id["SubNetA-${var.env}"],
      route_table_id = module.RouteTable.route-ids["custom-route-${var.env}"]
    },
    "SubnetBRoute-${var.env}" = {
      subnet_id      = module.Subnets.subnet-id["SubNetB-${var.env}"],
      route_table_id = module.RouteTable.route-ids["custom-route-${var.env}"]
    }
  }
}