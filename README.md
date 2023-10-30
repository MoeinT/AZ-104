# AZ-104
This repository is to study and prepare for the AZ-104 microsoft certificate; we'll review the most important resources that are a target for this certification. They're the required components to become an Azure Administrator. 

# Deploy and manage Azure Compute Resources
There are a variety of Azure Compote Resources available in Azure. We'll go through all of them one by one. We'll also provide Terraform configurations to deploy that resource into Azure.

## Virtual Machine
Imagine a scenario where we'd like to deploy a web application; for this, we would need servers to host the application, we would also need storage to store data associated with the application, and we also need networking; so, all the physical servers need to be part of a network. 

Within Azure, we can take advantage of Cloud Computing concepts and provision a Virtual Machine in the cloud. In addition to the virtual machine, you will see other resources that get created as part of the virtual machine resource, such as the network interface, the disk, network security group, and the virtual network. Let's dive deeper into each components of our network resources:

### Azure Virtual Network
This resources represents a virtual network in Azure, which is a logical isolated network in which Azure services are deployed. Vnets allow your Azure Services to securely communicate with one another, the internet, and on-premise networks. When defining a VNet, we need to specify an ip address space, which is a range of ip addresses available to resources within the Vnet. 
### Subnets
Subnets are a subdivision of the virtual network and is used to divide the Vnet into smaller and more manageable pieces. Subnets have their own ip ranges, that is a subset of the ip ranges of the Vnet. Here are the benefits of subnets:
- **Resource organization -** We can have different subnets for VMs, databases, web applications and so on.
- **Network security and isolation -** Each subnet has its own range of ip addresses, and resources within each subnet are completely
isolated from one another creating an additional level of security. In addition, Network Security Groups can be associated to each subnet acting as a firewall controlling inbound and outbound traffic to network interfaces.
### Azure Network Interface
An Azure network interface is a networking component that connects Azure services to a subnet within a Virtual Network. 
### Azure Security Groups
Network interfaces can have associated Network Security Groups (NSGs) that control inbound and outbound traffic to the associated VM or other resources. NSGs are used to define security rules to allow or deny traffic based on source and destination IP addresses, ports, and protocols.
### Deploying a Virtual Machine
- Create an [Azure Virtual Network](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network.html) and provide a range of IP addresses available to resources within this Vnet using the CIDR notation. 
- Create an [Azure Subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) within the above Vnet and provide a subset of IP Addresses in the Vnet
- Create an [Azure Public IP](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip)  to be able to connect to the VM from the internet 
- Create an [Azure Network Interface](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) and associate it with the public IP
- Create an [Azure network Security Group](azurerm_network_security_group) and an [Azure Network Interface Security Group Association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association) resource to associate the network interface to the security group
- Finally, create the [Azure Virtual Machine](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine) and associate it to the network interface created above
### Conneting to the virtual network 
Modify the inbound rules within the Security Group settings and make sure the RDP is allowed 
We can use the Remote Desktop Protocol to download a RDP file and install locally to connect to a virtual machine.
