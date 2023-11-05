# Create an Azure Managed Disk
module "Disks" {
  source = "../../CommonModules/AzureManagedDisks"
  properties = {
    "vm-disk-${var.env}" = {
      location             = module.Rg.rg-locations["az-104-${var.env}"],
      resource_group_name  = module.Rg.rg-names["az-104-${var.env}"],
      storage_account_type = "Standard_LRS",
      create_option        = "Empty",
      disk_size_gb         = "10",
      tags = {
        environment = var.env
      }
    }
  }
}

# Attach a disk to a VM
module "VmDiskAttachment" {
  source = "../../CommonModules/VmDiskAttachment"
  properties = {
    "vm-disk-attach-${var.env}" = {
      managed_disk_id    = module.Disks.disk-id["vm-disk-${var.env}"],
      virtual_machine_id = module.LinuxVM.vm-id["appvm-linux-${var.env}"],
      lun                = 0,
      caching            = "ReadOnly"
    }
  }
}