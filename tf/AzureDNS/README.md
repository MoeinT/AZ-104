# Setting up DNS in Azure: Local DNS vs. Azure Private DNS Zone
In this comprehensive guide, we will cover two approaches to setting up DNS within an Azure Virtual Network: one using Active Directory Domain Services (AD DS) with a local DNS server and another utilizing Azure Private DNS Zone. Additionally, we will integrate Infrastructure as Code (IaC) principles using Terraform to ensure consistency, scalability, and ease of management in our deployment process.

## Infrastructure as Code with Terraform
Our entire Azure network resources, including the virtual network, subnets, VMs, network security groups and rule within those, Vnet peeting, adding "A" records, and linking DNS and Vnets, were deployed using Infrastructure as Code (IaC) principles with Terraform. This approach ensures consistency, scalability, and ease of management in our deployment process.

## Approach 1: Active Directory Domain Services (AD DS) Setup
Active Directory Domain Services (AD DS) is a Microsoft Windows Server feature that provides central authentication and authorization services for a network. By setting up AD DS within Azure, we establish a local DNS infrastructure for efficient name resolution and domain management. In this approach, we aim to establish efficient name resolution and domain management within the Azure environment. Here are the steps:

### Steps:
#### 1. Deploy Virtual Network and Subnets:
- Create a Virtual Network (VNet) in your Azure portal.
- Within the VNet, create two subnets: one for the DNS server and one for the web server.
#### 2. Deploy Virtual Machines:
- Within each subnet, deploy a virtual machine.
- Name the VM in the subnet intended for DNS server as ```dns-server``` and the other as ```web-server```.
#### 3. Install and Configure Active Directory Domain Services (AD DS):
- Log in to the dns-server virtual machine.
- Install Active Directory Domain Services.
- Promote the server to a domain controller.
- Specify the domain name as ```cloud2hub.com```.
#### 4 .Configure DNS Server for Virtual Network:
- Add the private IP address of the dns-server virtual machine to the VNet DNS server settings.
#### 5. Add Web Server to Domain:
- Join the web-server virtual machine to the cloud2hub.com domain.
- This action automatically adds an "A" record within the DNS server, enabling DNS resolution for ```web-server.cloud2hub.com```.
- Install and configure Internet Information Services (IIS) on the web-server virtual machine to listen to requests.
#### 6. Restart Web Server:
- Restart the web-server virtual machine to apply the DNS settings.
#### 7. Test DNS Resolution:
- Use a fully qualified domain name (FQDN) to connect to the web server virtual machine from the DNS-server VM using ```web-server.cloud2hub.com```

## Approach 2: Azure Private DNS Zone Setup
Azure Private DNS Zone is a managed DNS service provided by Microsoft Azure. It allows users to create and manage custom DNS domains, enabling domain name resolution within Azure Virtual Networks. Here are the steps:
### Steps: 
#### 1. Create Virtual Networks and Subnets:
- Create two Virtual Networks: ```web-Vnet``` and ```client-Vnet```.
- Create corresponding subnets: ```webSubnet``` and ```clientSubnet``` in each VNet.
#### 2. Deploy Virtual Machines:
- Deploy a virtual machine in each subnet, web-vm and client-vm within webSubnet & clientSubnet, respectively.
- Establish VNet peering between web-Vnet and client-Vnet to enable communication.
#### 3. Vnet Peeting
- Create Vnet peerings to allow the client-vm to communicate with the web-vm as if they were part of the same network. Make sure the connection is established on both directions. By using VNet peering and virtual network links, we demonstrate the flexibility of Azure Private DNS Zones to be linked to one or more virtual networks, enabling centralized DNS management across multiple network environments. This setup ensures efficient domain name resolution and seamless connectivity within Azure Virtual Networks.
#### 3. Azure Private DNS Zone Configuration:
- Create a Azure Private DNS Zones: ```cloud2hub.com```
#### 4. Virtual Network Links:
- Associate the Private DNS Zone with both Vnets by creating two Vnet links; you can do so by creating virtual network links. 
- Enable auto-registration for the link to the web-Vnet to create "A" records automatically for web-vm.