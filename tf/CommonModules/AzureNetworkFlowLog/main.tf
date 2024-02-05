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

resource "azurerm_network_watcher_flow_log" "NetworkWatherFlowLog" {
  for_each             = var.properties
  network_watcher_name = each.value.network_watcher_name
  resource_group_name  = each.value.resource_group_name
  name                 = can(each.value.network_watcher_name) ? each.value.network_watcher_name : each.key

  network_security_group_id = each.value.network_security_group_id
  storage_account_id        = each.value.storage_account_id
  enabled                   = lookup(each.value, "enabled", true)

  retention_policy {
    enabled = lookup(each.value.retention_policy, "enabled", true)
    days    = lookup(each.value.retention_policy, "days", 7)
  }

  dynamic "traffic_analytics" {
    for_each = can(each.value.traffic_analytics) ? [1] : []
    content {
      enabled               = lookup(each.value.traffic_analytics, "enabled", true)
      workspace_id          = each.value.traffic_analytics.workspace_id
      workspace_region      = each.value.traffic_analytics.workspace_region
      workspace_resource_id = each.value.traffic_analytics.workspace_resource_id
      interval_in_minutes   = each.value.traffic_analytics.interval_in_minutes
    }
  }
}