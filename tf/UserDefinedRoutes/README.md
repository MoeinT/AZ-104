# User Defined Routes in Azure Virtual Networks
##  Overview
User Defined Routes (UDR) in Azure allow users to define custom routes for network traffic within a Virtual Network (VNet). By default, Azure uses system routes to manage traffic flow between resources within a VNet. However, in certain scenarios, users may require more control over routing to optimize traffic flow or implement specific network configurations.

This documentation outlines the usage of User Defined Routes within Azure Virtual Networks. We'll explore a practical example where UDRs are leveraged to direct traffic from a source virtual machine through a Virtual Network Appliance (VNA) before reaching the target virtual machine.

## Architecture 
In this architecture, we have a Virtual Network (VNet) with three subnets: SubNetA, SubNetB, and SubNetCentral. Each subnet hosts a virtual machine: appvmA, appvmB, and appvmCentral, respectively. All the necessary infrastructure has been provisioned using Terraform. This includes:

- Creation of Virtual Network and Subnets
- Deployment of Virtual Machines within the respective subnets
- Configuration of network interfaces and security groups, and associating them with their respective subnets

## Use Case
In our scenario, we have installed an internet service on appvmB and need to allow access from appvmA. However, instead of a direct communication path, we want the traffic to pass through appvmCentral for additional networking functions or inspection.

<p align="center">
  <img width="500" height="300" src=./assets/UserDefinedRoutes.png>
</p>