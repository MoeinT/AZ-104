module "NetworkWatcher" {
  source = "../../CommonModules/AzureNetworkWatcher"
  properties = {
    "appvm-network-watcher-${var.env}" = {
      location            = module.Rg.rg-locations["az-104-${var.env}"],
      resource_group_name = module.Rg.rg-names["az-104-${var.env}"],
    }
  }
}

module "VMExtension" {
  source = "../../CommonModules/AzureVMExtension"
  properties = {
    "source-vmextension-${var.env}" = {
      name                       = "source-vmextension"
      virtual_machine_id         = module.WindowsVM.vm-id["source-vm-${var.env}"]
      publisher                  = "Microsoft.Azure.NetworkWatcher"
      type                       = "NetworkWatcherAgentWindows"
      type_handler_version       = "1.4"
      auto_upgrade_minor_version = true
    },
    "target-vmextension-${var.env}" = {
      name                       = "target-vmextension"
      virtual_machine_id         = module.WindowsVM.vm-id["target-vm-${var.env}"]
      publisher                  = "Microsoft.Azure.NetworkWatcher"
      type                       = "NetworkWatcherAgentWindows"
      type_handler_version       = "1.4"
      auto_upgrade_minor_version = true
    }
  }
}

# Connection monitor between source and target virtual machines
module "ConnectionMonitor" {
  source = "../../CommonModules/AzureConnectionMonitor"
  properties = {
    "appvm-conn-monitor" = {
      network_watcher_id = module.NetworkWatcher.networkwatcher-id["appvm-network-watcher-${var.env}"]
      location           = module.Rg.rg-locations["az-104-${var.env}"],
      test_configuration = {
        name                      = "vmtest"
        protocol                  = "Http"
        test_frequency_in_seconds = 60,
        http_configuration = {
          port   = 80,
          method = "Get"
        }
      },
      test_group = {
        name                     = "vmtestgroup"
        destination_endpoints    = ["target-${var.env}"]
        source_endpoints         = ["source-${var.env}"]
        test_configuration_names = ["vmtest"]
      }
      endpoint = {
        "source-${var.env}" = {
          target_resource_id   = module.WindowsVM.vm-id["source-vm-${var.env}"]
          target_resource_type = "AzureVM"
        },
        "target-${var.env}" = {
          target_resource_id   = module.WindowsVM.vm-id["target-vm-${var.env}"],
          target_resource_type = "AzureVM"
        }
      }
    }
  }
}