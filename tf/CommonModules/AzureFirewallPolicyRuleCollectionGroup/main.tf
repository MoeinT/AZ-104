terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_firewall_policy_rule_collection_group" "CollectionGroup" {
  for_each           = var.properties
  name               = can(each.key.name) ? each.value.name : each.key
  firewall_policy_id = each.value.firewall_policy_id
  priority           = each.value.priority

  # A number of nat_rule_collection blocks in a loop
  dynamic "nat_rule_collection" {
    for_each = each.value.nat_rule_collection
    content {
      name     = can(nat_rule_collection.value.name) ? nat_rule_collection.value.name : nat_rule_collection.key
      priority = nat_rule_collection.value.priority
      action   = lookup(nat_rule_collection.value, "action", "Dnat")
      rule {
        name                = nat_rule_collection.value.rule.name
        translated_address  = nat_rule_collection.value.rule.translated_address
        translated_port     = nat_rule_collection.value.rule.translated_port
        source_addresses    = lookup(nat_rule_collection.value.rule, "source_addresses", [])
        destination_ports   = nat_rule_collection.value.rule.destination_ports
        destination_address = nat_rule_collection.value.rule.destination_address
        protocols           = nat_rule_collection.value.rule.protocols
      }
    }
  }
}