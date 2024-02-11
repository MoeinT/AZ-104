# Introduction to Azure Firewall
Azure Firewall is a cloud-native network security service that provides centralized, high-security, and low-latency traffic filtering for virtual networks (VNets) in Azure. It acts as a secure intermediary between the internet and our Azure resources, offering stateful inspection, application-level filtering, and threat intelligence integration to protect our network assets.

# Scenario and Architecture
In this exercise, we designed a network architecture within Azure to control outbound internet traffic from a virtual machine (VM) using Azure Firewall. The architecture comprises the following key elements:

## VM Subnet
This subnet hosts the virtual machine (VM) requiring outbound internet access while being subject to monitoring and restriction.

## Azure Firewall Subnet
Here resides Azure Firewall, our centralized network security solution tasked with inspecting and filtering outbound traffic from the VM to the internet.

### Azure Firewall Configuration
Within Azure Firewall, a policy has been created and attached. This policy includes a NAT rule facilitating access to the VM. By implementing this NAT rule, users can securely log into the VM from the internet while ensuring traffic is logged and monitored.

## User-Defined Route (UDR)
To enforce all outbound traffic from the VM through Azure Firewall, we implemented a user-defined route. This route designates Azure Firewall as the next hop for all outbound traffic originating from the VM. This configuration ensures that all communication undergoes inspection and filtering by Azure Firewall before reaching its destination on the internet.

# Infrastructure as Code with Terraform
Our entire Azure network setup, including the virtual network, subnets, Azure Firewall, VM, policy configurations, and user-defined route, was provisioned using Infrastructure as Code (IaC) principles with Terraform. This approach ensures consistency, scalability, and ease of management in our deployment process.
<p align="center">
  <img width="500" height="400" src=./assets/AzureFirewall.png>
</p>