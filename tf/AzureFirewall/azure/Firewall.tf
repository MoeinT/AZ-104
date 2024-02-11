# Firewall Policy
module "FirewallPolicies" {
  source = "../../CommonModules/AzureFirewallPolicy"
  properties = {
    "app-firewallpolicy-${var.env}" = {
      location            = module.Rg.rg-locations["az-104-${var.env}"],
      resource_group_name = module.Rg.rg-names["az-104-${var.env}"],
      sku                 = "Standard"
    }
  }
}

# Firewall for the AppVm
module "Firewalls" {
  source = "../../CommonModules/AzureFirewall"
  properties = {
    "app-firewall-${var.env}" = {
      location            = module.Rg.rg-locations["az-104-${var.env}"],
      resource_group_name = module.Rg.rg-names["az-104-${var.env}"],
      sku_name            = "AZFW_VNet",
      sku_tier            = "Standard",
      firewall_policy_id  = module.FirewallPolicies.firewallpolicy-id["app-firewallpolicy-${var.env}"]
      # Assigning a public Ip and an empty subnet to this firewall
      ip_configuration = {
        name                 = "appfirewall-ipconfig-${var.env}"
        subnet_id            = module.Subnets.subnet-id["AzureFirewallSubnet-${var.env}"]
        public_ip_address_id = module.publicIPs.publicIp-id["firewall-public-ip-${var.env}"]
      }
    }
  }
}

# NAT rule to log into the VM through RDP
module "AzureFirewallPolicyCollectionGroup" {
  source = "../../CommonModules/AzureFirewallPolicyRuleCollectionGroup"
  properties = {
    "appvm-${var.env}" = {
      # The policy that this rule belongs to
      firewall_policy_id = module.FirewallPolicies.firewallpolicy-id["app-firewallpolicy-${var.env}"]
      priority           = 100,
      # The Azure Firewall and Virtual Machine resources should be deployed first
      depends_on = [module.WindowsVM, module.Firewalls]
      # A NAT rule to allow RDP connection to the VM
      nat_rule_collection = {
        "appvm-rule-${var.env}" = {
          priority = 100
          rule = {
            name = "app-vm-natrule-${var.env}"
            # The IP address of the machine using RDP
            source_addresses = [var.source_addresses]
            # TCP protocol
            protocols = ["TCP"]
            # The post on the firewall side
            destination_ports = [4000]
            # Public IP address of the firewall
            destination_address = module.publicIPs.publicIp-address["firewall-public-ip-${var.env}"]
            # The IP address of the target virtual machine
            translated_address = data.azurerm_virtual_machine.app-vm.private_ip_address
            # The port on the VM side
            translated_port = "3389"
          }
        },
      }
    }
  }
}