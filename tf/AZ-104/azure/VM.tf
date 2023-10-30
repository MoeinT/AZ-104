# This public IP address allows connectivity from the internet
resource "azurerm_public_ip" "VMPublicIP" {
  name                = "appvm-public-ip-${var.env}"
  location            = azurerm_resource_group.Rg.location
  resource_group_name = azurerm_resource_group.Rg.name
  allocation_method   = "Static"
  sku                 = "Basic"
}

# Security Group for the VM Network Interface
resource "azurerm_network_security_group" "VMNSG" {
  name                = "VmNSG-${var.env}"
  location            = azurerm_resource_group.Rg.location
  resource_group_name = azurerm_resource_group.Rg.name
}

# Create a NIC and associate it to the Public IP
resource "azurerm_network_interface" "VMNetInterface" {
  name                = "example-nic-${var.env}"
  location            = azurerm_resource_group.Rg.location
  resource_group_name = azurerm_resource_group.Rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.SubNet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.VMPublicIP.id
  }
}

# Associate the security group to the network interface
resource "azurerm_network_interface_security_group_association" "NIC_NSG" {
  network_interface_id      = azurerm_network_interface.VMNetInterface.id
  network_security_group_id = azurerm_network_security_group.VMNSG.id
}

# Define the Virtual Machine
resource "azurerm_windows_virtual_machine" "AppVm" {
  name                = "appvm-${var.env}"
  resource_group_name = azurerm_resource_group.Rg.name
  location            = azurerm_resource_group.Rg.location
  size                = "Standard_D2s_v3"
  admin_username      = var.vm_admin_username
  admin_password      = var.vm_admin_password
  network_interface_ids = [
    azurerm_network_interface.VMNetInterface.id,
  ]

  os_disk {
    caching              = "None"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
}