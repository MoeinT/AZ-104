# Introduction to Azure Virtual Network Peering

Azure Virtual Network (VNet) Peering is a networking feature that enables connecting two virtual networks in the same or different regions through the Azure backbone network. It allows resources in those virtual networks to communicate securely with each other as if they were part of the same network.

# Scenario and Architecture

In this exercise, we explored Azure VNet Peering by setting up two virtual networks: source-Vnet and target-Vnet. Each virtual network contained a subnet: source-subnet and target-subnet, respectively. Within these subnets, we deployed virtual machines equipped with public IP addresses for remote access via RDP.

Initially, we encountered connectivity issues when attempting to access services deployed in the target-Vnet from the source-Vnet. This was due to the isolation between the two virtual networks.

To resolve this, we implemented bidirectional VNet peering between source-Vnet and target-Vnet. This configuration allowed seamless and secure communication between the virtual machines residing in the different subnets across the two virtual networks.

## Importance of Virtual Network Peering

Virtual Network Peering offers several benefits:

**Simplified Network Configuration -** It eliminates the need for complex network setups or VPN gateways to enable communication between virtual networks.

**Improved Latency and Throughput -** Since communication occurs over Azure's backbone network, it typically offers lower latency and higher throughput compared to traditional network setups.

**Enhanced Security -** By default, traffic between peered virtual networks remains within the Azure backbone, ensuring data privacy and security.

**Cost Efficiency -** VNet peering is a cost-effective solution for connecting resources within Azure as it avoids the additional expenses associated with data transfer or VPN gateways.

# Network Watcher and Connection Monitor

To monitor the connectivity between virtual machines across the peered virtual networks, we deployed Azure Network Watcher along with Connection Monitor.

Azure Network Watcher provides tools to monitor, diagnose, and gain insights into the network infrastructure. It helps in identifying and resolving network issues efficiently.

Connection Monitor, a feature of Azure Network Watcher, continuously monitors connectivity between specified source and destination virtual machines. In our scenario, Connection Monitor played a crucial role in verifying the successful establishment of connectivity between the virtual machines across the peered virtual networks.

By leveraging Network Watcher and Connection Monitor, we were able to ensure the reliability and stability of the communication between the virtual machines deployed in the source-Vnet and target-Vnet, thus enhancing the overall performance and resilience of our Azure network architecture.

# Infrastructure as Code with Terraform
As our infrastructure requirements evolve, Terraform empowers us to scale our network resources seamlessly. Adding additional subnets, virtual machines, or peering connections can be achieved by simply updating our Terraform configuration files. Terraform also facilitated the deployment of Azure Network Watcher and Connection Monitor as integral parts of our network monitoring strategy.

## Terraform modules
Terraform modules played a central role in organizing and structuring our deployment. Each aspect of our Azure infrastructure, including virtual networks, subnets, virtual machines, network security groups, and monitoring services, was encapsulated within its own Terraform module.

By modularizing our Terraform configuration, we ensured a clear separation of concerns and enhanced maintainability. Each module represented a distinct component of our architecture, making it easier to understand, update, and extend our infrastructure as needed. Below we can see the architecture diagram used in this exercise: 

<p align="center">
  <img width="450" height="300" src=./assets/ConnectionMonitor.png>
</p>