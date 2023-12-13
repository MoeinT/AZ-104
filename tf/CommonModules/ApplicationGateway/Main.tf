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

resource "azurerm_application_gateway" "network" {
  for_each            = var.properties
  name                = each.key
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  enable_http2        = lookup(each.value, "enable_http2", false)

  sku {
    name     = each.value.sku
    tier     = each.value.tier
    capacity = each.value.capacity
  }

  # Conditional block
  dynamic "autoscale_configuration" {
    for_each = can(each.value.autoscale_configuration) ? [1] : []
    content {
      min_capacity = each.value.autoscale_configuration.min_capacity
      max_capacity = each.value.autoscale_configuration.max_capacity
    }
  }

  # loop through the block
  dynamic "gateway_ip_configuration" {
    for_each = each.value.gateway_ip_configuration
    content {
      name      = gateway_ip_configuration.key
      subnet_id = gateway_ip_configuration.value.subnet_id
    }
  }

  dynamic "frontend_port" {
    for_each = each.value.frontend_port
    content {
      name = frontend_port.key
      port = frontend_port.value.port
    }
  }

  dynamic "backend_address_pool" {
    for_each = each.value.backend_address_pool
    content {
      name         = backend_address_pool.key
      fqdns        = lookup(backend_address_pool.value, "fqdns", null)
      ip_addresses = lookup(backend_address_pool.value, "ip_addresses", null)
    }
  }

  dynamic "frontend_ip_configuration" {
    for_each = each.value.frontend_ip_configuration
    content {
      name                 = frontend_ip_configuration.key
      public_ip_address_id = frontend_ip_configuration.value.public_ip_address_id
    }
  }

  dynamic "http_listener" {
    for_each = each.value.http_listener
    content {
      name                           = http_listener.key
      frontend_ip_configuration_name = http_listener.value.frontend_ip_configuration_name
      frontend_port_name             = http_listener.value.frontend_port_name
      protocol                       = http_listener.value.protocol
    }
  }

  dynamic "backend_http_settings" {
    for_each = each.value.backend_http_settings
    content {
      name                  = backend_http_settings.key
      cookie_based_affinity = backend_http_settings.value.cookie_based_affinity
      path                  = lookup(backend_http_settings.value, "path", null)
      port                  = backend_http_settings.value.port
      protocol              = backend_http_settings.value.protocol
      request_timeout       = backend_http_settings.value.request_timeout
    }
  }

  dynamic "request_routing_rule" {
    for_each = each.value.request_routing_rule
    content {
      name                       = request_routing_rule.key
      priority                   = lookup(request_routing_rule.value, "priority", null)
      rule_type                  = request_routing_rule.value.rule_type
      http_listener_name         = request_routing_rule.value.http_listener_name
      backend_address_pool_name  = request_routing_rule.value.backend_address_pool_name
      backend_http_settings_name = request_routing_rule.value.backend_http_settings_name
    }
  }
}