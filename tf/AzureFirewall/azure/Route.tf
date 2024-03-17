# Create a route table to forward all traffic that are going to the internet through the firewall
module "RouteTable" {
  source = "../../CommonModules/AzureRouteTable"
  properties = {
    "firewallrouting-${var.env}" = {
      location                      = module.Rg.rg-locations["az-104-${var.env}"],
      resource_group_name           = module.Rg.rg-names["az-104-${var.env}"],
      disable_bgp_route_propagation = false
      route = {
        "route-${var.env}" = {
          # All traffic
          address_prefix = "0.0.0.0/0"
          # The traffic should be forwarded to the central VM, hence a virtual appliance
          next_hop_type = "VirtualAppliance",
          # The public IP address of the firewall
          next_hop_in_ip_address = module.publicIPs.publicIp-address["firewall-public-ip-${var.env}"]
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
      subnet_id      = module.Subnets.subnet-id["subnetA-${var.env}"],
      route_table_id = module.RouteTable.route-ids["firewallrouting-${var.env}"]
    }
  }
}