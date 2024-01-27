# Virtual Network Peering
Azure Virtual Network (VNet) peering is a networking feature that allows you to connect multiple Azure virtual networks seamlessly. When two virtual networks are peered, they appear as one for connectivity purposes, and resources in these VNets can communicate with each other as if they were on the same network. This connectivity is achieved without the need for additional hardware or virtual appliances. We can use the ```azurerm_virtual_network_peering``` instance to deploy that using Terraform. For bidirectional communications, you need to create two instances of the ```azurerm_virtual_network_peering``` resource—one for each direction of the peering relationship.

## Use Cases
Imagine a scenario where you have a multi-tier application with different components deployed in separate VNets (e.g., web tier, application tier, database tier). VNet peering allows secure communication between the different tiers of your application without exposing unnecessary endpoints to the public internet.

Another scenario is when you have centralized network services (e.g., Azure Firewall, Azure Bastion) deployed in a separate VNet. VNet peering allows other VNets to access centralized network services, providing a consistent and centralized approach to network security and management.

By using VNet peering, you can create separate VNets for different departments or projects and control communication between them, ensuring resource isolation while still allowing necessary connectivity.

## Architecture diagram