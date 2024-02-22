# Setting up a Local DNS Server within an Azure Virtual Network
In this guide, we will walk through the process of setting up a local DNS server within an Azure Virtual Network. This setup involves deploying a Virtual Network with two subnets, deploying virtual machines within each subnet, configuring Active Directory Domain Services, and establishing DNS resolution.

## Infrastructure as Code with Terraform
Our entire Azure network setup, including the virtual network, subnets, VMs, and policy configurations was provisioned using Infrastructure as Code (IaC) principles with Terraform. This approach ensures consistency, scalability, and ease of management in our deployment process.

## Prerequisites
- Azure subscription
- Basic understanding of Azure Virtual Networks and Virtual Machines

## Steps:
### 1. Deploy Virtual Network and Subnets:
- Create a Virtual Network (VNet) in your Azure portal.
- Within the VNet, create two subnets: one for the DNS server and one for the web server.
### 2. Deploy Virtual Machines:
- Within each subnet, deploy a virtual machine.
- Name the VM in the subnet intended for DNS server as ```dns-server``` and the other as ```web-server```.
### 3. Install and Configure Active Directory Domain Services (AD DS):
- Log in to the dns-server virtual machine.
- Install Active Directory Domain Services.
- Promote the server to a domain controller.
- Specify the domain name as cloud2hub.com.
### 4 .Configure DNS Server for Virtual Network:
- Add the private IP address of the dns-server virtual machine to the VNet DNS server settings.
### 5. Add Web Server to Domain:
- Join the web-server virtual machine to the cloud2hub.com domain.
- This action automatically adds an "A" record within the DNS server, enabling DNS resolution for ```web-server.cloud2hub.com```.
- Install and configure Internet Information Services (IIS) on the web-server virtual machine to listen to requests.
### 6. Restart Web Server:
- Restart the web-server virtual machine to apply the DNS settings.
### 7. Test DNS Resolution:
- Use a fully qualified domain name (FQDN) to connect to the web server virtual machine from the DNS-server VM using ```web-server.cloud2hub.com```

## Conclusion:
Setting up a local DNS server within an Azure Virtual Network provides efficient name resolution for your network resources. By following these steps, you can establish a reliable DNS infrastructure tailored to your specific needs within Azure.

This guide serves as a concise reference for setting up a local DNS server within an Azure Virtual Network. Feel free to expand and customize it according to your project requirements and environment.