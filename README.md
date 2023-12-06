# AZ-104
This repository is to study and prepare for the AZ-104 microsoft certificate; we'll review the most important resources that are a target for this certification. They're the required components to become an Azure Administrator. 

All the resources that are subject to this certification, such as networking resources, virtual machine, Azure Kubernetes etc. will be deployed and managed using Infrastructure as Code (IaC) concepts with Terraform as part of a CI/CD pipeline.

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
### Deploying a VM
- Create an [Azure Virtual Network](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network.html) and provide a range of IP addresses available to resources within this Vnet using the CIDR notation. 
- Create an [Azure Subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) within the above Vnet and provide a subset of IP Addresses in the Vnet
- Create an [Azure Public IP](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip)  to be able to connect to the VM from the internet 
- Create an [Azure Network Interface](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) and associate it with the public IP
- Create an [Azure network Security Group](azurerm_network_security_group) and an [Azure Network Interface Security Group Association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association) resource to associate the network interface to the security group
- Finally, create the [Azure Virtual Machine](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine) and associate it to the network interface created above
### Conneting to the VM
Modify the inbound rules within the Security Group settings and make sure the RDP is allowed to connect to the virtual machine. We can use the Remote Desktop Protocol to download a RDP file and install locally to connect to a virtual machine.

### Authentication to a Linux VM
Under the tf/CommonModules folder, we've defined a separate module for deploying a linux-based virtual machine. We've allowed the SSH Key block to be an optional input by using [Dynamic Blocks in Terraform](https://developer.hashicorp.com/terraform/language/expressions/dynamic-blocks). We've implemented the same logic for the admin_password parameter using the [Lookup function in Terraform](https://developer.hashicorp.com/terraform/language/functions/lookup). One of the admin_password and admin_ssh_key parameters should be provided by the user for authentication. 

When deploying a Linux-based virtual machine (VM) in Azure, you have two primary options for authenticating and accessing the VM: using an *admin password* or an SSH key. Using a password for authentication is generally less secure than SSH keys. Passwords can be vulnerable to brute-force attacks. With an SSH key, you authenticate to the Linux VM using a pair of cryptographic keys: a public key (which is stored on the server) and a private key (which you keep on your local machine)

**NOTE -** It's recommended to not create SSH Keys with Terraform, since the private key generated by this resource will be stored unencrypted in the Terraform state file. Instead, we should generate a private key file outside of Terraform and distribute it securely to the system where Terraform will be run.

For our deployments, we've created an SSH Key pair using the Azure Console, and [used the public key data source](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/ssh_public_key) to access its public key within our configuration file and attach it to the virtual machine. 

### Azure managed disks 
Azure managed disks are storage volumes managed by Azure and used with virtual machines. Managed disks are like disks on a physical server, but virtualized. The available types of disks are ultra disks, premium solid-state drives (SSD), standard SSDs, and standard hard disk drives (HDD). See [Select a disk type for IaaS VMs](https://learn.microsoft.com/en-us/azure/virtual-machines/disks-types) for an overview of these disk types and potential scenarios. 

We used the [azure_managed_disk](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_disk) resource to provision an Azure Managed Disk in the cloud, and the [virtual_machine_data_disk_attachment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_data_disk_attachment) resource to attach that disk to the virtual machine in the Terraform codes. 

### Server-side encryption of Azure Disk Storage
It's worth mentioning that the data associated to a disk hosted in a data center in Azure is encrypted at rest. Reading that data would require an encryption key or access to the algorithm used to encrypt the data creating an additional level of security. Azure managed disks are encrypted by default using Azure Storage encryption, which does not impact performance and is provided at no additional cost. Users can also choose to enable encryption at host, which encrypts data on the VM host itself, ensuring end-to-end encryption for temporary disks, OS/data disk caches, and persisted data in Azure Storage.

Additionally, users have the flexibility to manage their encryption keys using either ***platform-managed keys*** (automatically managed by Microsoft) or ***customer-managed keys***, which allow greater control and the ability to manage access controls using Azure Key Vault or Azure Key Vault Managed Hardware Security Module (HSM). Read the [documentation](https://learn.microsoft.com/en-us/azure/virtual-machines/disk-encryption) for more details.

#### Using Customer Manager Encryption for Azure Managed Disk 
Many organizations prefer to use their own managed keys for encryption of disks attached to their Virtual Machine. Follow the below steps in Terraform:
- Once a key vault is created and in place, go ahead and create a [key vault key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_key)
- Create a [key vault encyption set](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/disk_encryption_set)
- Make sure the key vault encyption set has the required access to the key vault
- Stop/deallocate the virtual machine and attach the key encryption set to the Azure Managed disk

The above procedure allows us to use our own internal keys for encryption of data hosted in an Azure Managed Disk. We have managed all the above steps using Infrastructe as Code with Terraform. Follow the details under the ```tf/AZ-104/azure/Kv.tf``` and ```tf/AZ-104/azure/Disk.tf``` paths.

### Stopping/de-allocating vs Restarting a VM
When a VM is restarted, data within all OS disk, managed disk, and temporary disk will be intact; however, when a VM is stopped/deallocated, the data within the temporary disk is lost, but the data within OS and managed disk will still remain intact.

### Deploying an Azure KeyVault
For security reasons, we've used network access control lists within the Key Vault block in Terraform to only give access to Azure resources within a subnet. So, normally, all resources within a subnet would be able to communicate to the Key Vault. Before doing so, we need to specify in the subnet that it should have a service endpoint for the key vault. This ensures that resources within that subnet can communicate with the key vault securely without exposing traffic to the internet.

# Configure and manage virtual networking
In the prior section when taking about VMs, we had a quick introduction about certain networking aspects in Azure. Here we'll dive deeper into azure networking resources and concepts.

## Virtual network
In the previous chapter, we deployed a VM under a subnet within a Vnet. We managed all the required resources through a modular approach with Terraform. In this chapter, we'll go through details of address ranges, CIRDR notation, and finally deploy a Vnet with a specific IP ranges and go ahead and deploy a VM within it.

### IP address space and the CIDR notation
An IP address is 32-bit number represented as numbers in a human-readable way.

**What's an IP address -** An IP address consists of a network and a host portion. The network portion of an IP address helps identify which network a device is belongs to, so all devices within a subnet have the same network portion of a device; the host portion of an IP helps to identify the device within a network.

**Subnet mask -** A subnet mask determines the boundary between the network and host portions of an IP address. So, by comparing a subnet mask with the IP address, we can figure out the portion of the IP address that belongs to the network, and the portion that belongs to the host. With this knowledge, we can then figure out the number of possible hosts (IP addresses) within this network. As an exmple, consider the IP address ```192.168.1.1``` with the subnet mask of ```255.255.255.0```.

In binary, the IP address ```192.168.1.1``` is represented as ```11000000.10101000.00000001.00000001```, and the subnet mask ```255.255.255.0``` is represented as ```11111111.11111111.11111111.00000000```. By comparing the two, we can see that the first 24 bits is the network portion of the IP, and the digit 1 is the device id.

**CIDR Notation -** using CIDR notation, we can provide a range of IP address available to a virtual network. In CIDR notation, an IP address is followed by a forward slash ("/") and a number, which represents the length of the routing prefix, in other words, the number after the forward slash represents the length of the network portion of the IP address. So, the lower that number, the higher the number of hosts, devices or resources that can be accommodated within that network. The formula for calculating the size of a network is 2^(32 - prefix length). So, in an address range ```10.0.0.0/16```, 2^16 = 65536 devices can fit into this network, but in an address range of ```10.0.0.0/24```, only 2^8 = 256 IP addresses are available within the network, since the first 24 bits are taken by the network portion of the IP, and only the last digit is associated to the device. Compared to the subnet mask, it provides a simpler way of determining the IP address space.

**Private and public ip addresses -** Private IP addresses are deciated to private communications between resources within a Virtual Network; public ip addresses on the other hand, are a separate resource and are used for inbound communications from the internet to the resource. So, we can deploy a public ip address, attach it to a network interface, which is itself attached to a VM, to allow inbound communications to it from the internet.

**Secondary interface attached to a VM -** As discussed in the previous chapter, a network interface allows a VM to communictate within resources in a Vnet, on-premise resources and even the internet. There are some scnenarios where we would neet to attach a secondary network interface to a virtual machine. One network interface can be attached to a public ip allowing inbound communication with the internet, and the other network interface could be responsible to pass that traffic to other subnets. So, in certain architectural designs, a primary subnet can be dedicated to communicate with the internet.

**Network security group -** A NSG is a Microsoft managed service that can be attached to a network interface controlling inbound and outbound traffic to that interface; i.e., we can add a network security rule to allow inbound communications through port 80; this would allow HTTP requests to the VM attached to the interface. Within the network security rules, we can also add a source to allow communications from only specific sources, i.e., ip addresses; if the NSG is attached to multiple network interfaces, we can add a destination to only allow communications to a specific resource attached to that network interface, i.e., could be the private ip address of a VM. Regarding outbound traffic, by default all outbound communications are allowed, meaning that a network interface attached to a VM would allow it to communicate to the outside world, without any limit.

**Network security rule priority -** A number between 100 and 4096. Rules are processed in priority order, with lower numbers processed before higher numbers, because lower numbers have higher priority. Once traffic matches a rule, processing stops. So, if a rule denies access to port 80 with the priority 100, and another rule allows access to port 80 with priority 101, the access to port 80 will be denied, since the first rule is processed first and stops. Read more about security rules here in [this documentation](https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview). 

**Nework Security Group at the subnet level -** In the previous chapter, we've attached a NSG to a NIC, which itself was attached to a VM. Like this, we could control outbund/inboud communications to the VM; in some scenarios,we might want to attach a NSG at the subnet level, and control traffic to the whole resources within a subnet. For this, we can use the [azurerm_subnet_network_security_group_association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) resource in Terraform. 

**Application security groups -** Imagine a scenario where a large number of resources, i.e., Vms, in a subnet would like to communicate with a large number of VMs in another subnet. We would have to create a security rule for each one including their private IP address in the source and destination. This is a lot of manual work, and we would have to hardcode the resource private IP addresses into the VM. Instead, we can use [Application Security Groups](https://learn.microsoft.com/en-us/azure/virtual-network/application-security-groups). So, the way it works is that if there are 10 resources at the source, we can associate their network interfaces with an application security group, and choose that application security group as a source to the network security rule of the target resource. This way, we would not have to add the IP address of all the 10 resources and create 10 network security rule; instead, we can create one security rule for the application security rule.

## Azure Load Balancer
Imagine a scenario where there are a large number of requests to a web application hosted in a VM. In order to be able to handle this, we can host the application on multiple machines as part of a Virtual Machine Scale set. In such a scenario, we would need a mechanism to make sure the incoming requests don't fall on the same machine, and get evenly distributed across all machines. For this we can use the Azure Load Balancer service. So, in this case incoming requests from users/internet will go through the Azure Load Balancer first, and get distributed across the VMs. For this reason, if the load balancer is being accessed from the internet, we might need to assign a public IP address to it, and there's no need for the VMs to have one. 

**How to deploy and associate a Load Balancer to a Virtual Machine -**

**Load Balancer Health Probe -** The role of the Load Balancer is to forward the incoming requests to the VMs running an application. Before doing so, it needs to make sure the VMs are up & running. In case of failure on any of the Virtual Machines, it will avoid forwarding the incoming requests to that VM. Here's the [documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_probe) on how to deploy a Load Balancer health probe. 

**Load Balancing Rules -** Through the Load Balancing Rules, we can define how the incoming requests should be routed to the VMs hosting the application. There might be multiple backend pools attached to the Load Balancer, so using the Load Balancing Rules, we can define which one(s) the incoming requests should be forwarded to. Here's the Terraform [documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_rule.html).

## Azure Bastion 
It's a service provided by Azure that allows secure RDP and SSH access to VMs within a Virtual Network. It acts as a gateway 