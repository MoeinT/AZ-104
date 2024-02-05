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

resource "azurerm_network_connection_monitor" "ConnectionMonitor" {
  for_each           = var.properties
  name               = can(each.value.name) ? each.value.name : each.key
  network_watcher_id = each.value.network_watcher_id
  location           = each.value.location

  dynamic "endpoint" {
    for_each = each.value.endpoint
    content {
      name                 = can(endpoint.value.name) ? endpoint.value.name : endpoint.key
      target_resource_id   = lookup(endpoint.value, "target_resource_id", null)
      target_resource_type = lookup(endpoint.value, "target_resource_type", null)
      dynamic "filter" {
        for_each = can(endpoint.value.filter) ? [1] : []
        content {
          item {
            address = filter.value.address
            type    = filter.value.type
          }
          type = filter.value.type
        }
      }
    }
  }

  test_configuration {
    name                      = each.value.test_configuration.name
    protocol                  = each.value.test_configuration.protocol
    test_frequency_in_seconds = each.value.test_configuration.test_frequency_in_seconds

    dynamic "http_configuration" {
      for_each = can(each.value.test_configuration.http_configuration) ? [1] : []
      content {
        port   = each.value.test_configuration.http_configuration.port
        method = each.value.test_configuration.http_configuration.method
      }
    }

    dynamic "tcp_configuration" {
      for_each = can(each.value.test_configuration.tcp_configuration) ? [1] : []
      content {
        port = each.value.test_configuration.tcp_configuration.port
      }
    }
  }

  test_group {
    name                     = each.value.test_group.name
    destination_endpoints    = each.value.test_group.destination_endpoints
    source_endpoints         = each.value.test_group.source_endpoints
    test_configuration_names = each.value.test_group.test_configuration_names
  }

  output_workspace_resource_ids = lookup(each.value, "output_workspace_resource_ids", null)
}