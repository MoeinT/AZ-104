locals {
  backendtags = {
    "Environment_Type"  = "Backend"
    "InfoSeC"           = "Confidential"
    "Technical_Contact" = "moin.torabi@gmail.com"
  }
  # Application gateway variables
  frontend_port_name             = "frontend-port-${var.env}"
  frontend_ip_configuration_name = "frontend-ip-${var.env}"
  listener_name                  = "http-listener-${var.env}"
  request_routing_rule           = "request-routing-rule-images-${var.env}"
  url_path_map_name              = "url-path-map-${var.env}"

  # App1
  backend_address_pool_name_images = "images-backendpool-${var.env}"
  http_setting_name_images         = "backend-setting-images-${var.env}"

  # App2
  backend_address_pool_name_videos = "videos-backendpool-${var.env}"
  http_setting_name_videos         = "backend-setting-videos-${var.env}"

  # Default Redirect on Root Context (/)
  redirect_configuration_name = "redirect-configuration-${var.env}"
}