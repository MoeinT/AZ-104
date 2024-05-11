# AZ-104
This repository is to study and prepare for the AZ-104 microsoft certificate; we'll review the most important resources that are a target for this certification. They're the required components to become an Azure Administrator.

All the resources that are subject to this certification, such as networking resources, virtual machine, Azure Kubernetes etc. will be deployed and managed using Infrastructure as Code (IaC) concepts with Terraform as part of a CI/CD pipeline.

# Configure and manage virtual networks for Azure administrators
## Azure Virtual Network
This resources represents a virtual network in Azure, which is a logical isolated network in which Azure services are deployed. Vnets allow your Azure Services to securely communicate with one another, the internet, and on-premise networks. When defining a VNet, we need to specify an ip address space, which is a range of ip addresses available to resources within the Vnet. 

## IP address space
An IP address is a 32-bit number represented in a human-readable way. An IP address consists of a network and a host portion. The network portion of an IP address helps identify which network a device belongs to; so all devices within a subnet have the same network portion; the host portion helps to identify the device within a network.

### Subnet mask
A subnet mask determines the boundary between the network and host portions of an IP address. So, by comparing a subnet mask with the IP address, we can figure out the portion of the IP address that belongs to the network, and the portion that belongs to the host. With this knowledge, we can then figure out the number of possible hosts (IP addresses) within this network. As an exmple, consider the IP address ```192.168.1.1``` with the subnet mask of ```255.255.255.0```.

In binary, the IP address ```192.168.1.1``` is represented as ```11000000.10101000.00000001.00000001```, and the subnet mask ```255.255.255.0``` is represented as ```11111111.11111111.11111111.00000000```. By comparing the two, we can see that the first 24 bits is the network portion of the IP, and the digit 1 is the device id.

### CIDR Notation
using CIDR notation, we can provide a range of IP addresses available to a virtual network. In CIDR notation, an IP address is followed by a forward slash ("/") and a number, which represents the length of the routing prefix, in other words, the number after the forward slash represents the length of the network portion of the IP address. So, the lower that number, the higher the number of hosts, devices or resources that can be accommodated within that network. The formula for calculating the size of a network is 2^(32 - prefix length). So, in an address range ```10.0.0.0/16```, 2^16 = 65536 devices can fit into this network, but in an address range of ```10.0.0.0/24```, only 2^8 = 256 IP addresses are available within the network, since the first 24 bits are taken by the network portion of the IP, and only the last digit is associated to the device. Compared to the subnet mask, it provides a simpler way of determining the IP address space.

### Private and public ip addresses
Private IP addresses are dedicated to private communications between resources in a Virtual Network; public ip addresses on the other hand, are a separate resource and are used for inbound communications from the internet to the resource. So, we can deploy a public ip address, attach it to a network interface, which is itself attached to a VM, to allow inbound communications to it from the internet.

### Secondary interface attached to a VM
As discussed in the previous chapter, a network interface allows a VM to communictate within resources in a Vnet, on-premise resources and even the internet. There are some scnenarios where we would need to attach a secondary network interface to a virtual machine. One network interface can be attached to a public ip allowing inbound communication with the internet, and the other network interface could be responsible to pass that traffic to other subnets. So, in certain architectural designs, a primary subnet can be dedicated to communicate with the internet.

## Azure Subnets 
Subnets are a subdivision of the virtual network and is used to divide the Vnet into smaller and more manageable pieces. Subnets have their own ip ranges, that is a subset of the ip ranges of the Vnet. Here are the benefits of subnets:
- Resource organization: We can have different subnets for VMs, databases, web applications and so on.
- Network security and isolation: Each subnet has its own range of ip addresses, and resources within each subnet are completely isolated from one another creating an additional level of security. In addition, Network Security Groups can be associated to each subnet acting as 
a firewall controlling inbound and outbound traffic to network interfaces.

### Things to consider when using subnets
- **Consider service endpoints:**  You can limit access to Azure resources like an Azure storage account or Azure SQL database to specific subnets with a virtual network service endpoint. You can also deny access to the resources from the internet. You might create multiple subnets, and then enable a service endpoint for some subnets, but not others.
- **Consider Private linkes -** Azure Private Link provides connections from Azure Virtual Network to Microsoft Platform as a Service (PaaS), customer-owned, or Azure partner services. It simplifies the architecture and provides a secure connection to endpoints in Azure. The advantage of using a Private Link is that it allows resources within a Vnet to communicate within your target resources in Azure through Microsoft's backbone network infrastructure without having to go through the public internet.

## network security groups
A NSG is a Microsoft managed service that can be attached to a network interface as well as a subnet controlling inbound and outbound traffic; i.e., we can add a network security rule to allow inbound communications through port 80; this would allow HTTP requests to the VM attached to the interface. Within the network security rules, we can also add a source to allow communications from only specific sources, i.e., ip addresses; if the NSG is attached to multiple network interfaces, we can add a destination to only allow communications to a specific resource attached to that network interface, i.e., could be the private ip address of a VM. Regarding outbound traffic, by default all outbound communications are allowed, meaning that a network interface attached to a VM would allow it to communicate to the outside world, without any limit. Here's how the network security rules are assessed: 

- For inbound traffic, Azure first processes network security group security rules for any associated subnets and then any associated network interfaces.
- For outbound traffic, the process is reversed. Azure first evaluates network security group security rules for any associated network - interfaces followed by any associated subnets.

### Network security rule priority
A number between 100 and 4096. Rules are processed in priority order, with lower numbers processed before higher numbers, because lower numbers have higher priority. Once traffic matches a rule, processing stops. So, if a rule denies access to port 80 with the priority 100, and another rule allows access to port 80 with priority 101, the access to port 80 will be denied, since the first rule is processed first and stops. Read more about security rules here in [this documentation](https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview). 

### Nework Security Group at the subnet level
In the previous chapter, we've attached a NSG to a NIC, which itself was attached to a VM. Like this, we could control outbund/inboud communications to the VM; in some scenarios,we might want to attach a NSG at the subnet level, and control traffic to the whole resources within a subnet. For this, we can use the [azurerm_subnet_network_security_group_association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) resource in Terraform. 

### Application security groups
Imagine a scenario where a large number of resources, i.e., Vms, in a subnet would like to communicate with a large number of VMs in another subnet. We would have to create a security rule for each one including their private IP address in the source and destination. This is a lot of manual work, and we would have to hardcode the resource private IP addresses into the VM. Instead, we can use [Application Security Groups](https://learn.microsoft.com/en-us/azure/virtual-network/application-security-groups). So, the way it works is that if there are 10 resources at the source, we can associate their network interfaces with an application security group, then use the application security group as a source or destination in the network security group rules. This way, we would not have to add the IP address of all the 10 resources and create 10 network security rule; instead, we can create one security rule for the application security rule. Find [here](https://learn.microsoft.com/en-us/training/modules/configure-network-security-groups/6-implement-asgs) in the documentation more details about benefits of Application Security Groups. **Application security groups provide an application-centric view of infrastructure and simplify rule management.**

## Configure Azure DNS
A DNS domain is a human-readable label assigned to a group of devices, services, or resources on the internet. DNS records are essential components of the DNS infrastructure that help translate human-readable domain names into machine-readable IP addresses

Now, Azure DNS is a service provided by Microsoft Azure that allows you to manage the DNS records for your domain using their infrastructure. Here's how Azure DNS helps you manage your DNS domain:

**Domain Registration -** You can register a custom domain using a domain registrar; once you own the domain, we can use DNS settings and point it towards a resource in Azure. 

**DNS Records Management -** Azure DNS provides a platform for you to create, update, and delete DNS records associated with your domain. These records include things like A records (to map domain names to IP addresses), CNAME records (alias records), MX records (mail exchange), and more.

**Scalability and Reliability -** Azure DNS leverages the scalability and reliability of Microsoft's global network infrastructure. This ensures that your DNS records are distributed across multiple servers in different locations, providing low-latency and high-availability DNS resolution for your domain.

**Integration with Azure Services -** If you are using other Azure services (like Azure App Service, Azure Virtual Machines, etc.), Azure DNS seamlessly integrates with them, allowing you to easily associate your domain with these services.

**Security Features -** Azure DNS provides security features such as Azure DNS Private Zones, which allow you to host private DNS domains in Azure and resolve them within your virtual network, enhancing security for internal services.

### Verify a Custom DNS
We cannot associate a custom domain name to any of our resources within a subscription unless it's verified. For this, we need to verify the ownership of the DNS. The verification process involves adding a DNS record of the custom domain name. After it's been added, Azure queries the DNS domain for presence of that record. Once verified, the custom domain name is added to the Microsoft Entra instance. 

### Azure DNS Zone
An Azure DNS zone hosts the DNS records for a domain. To begin hosting your domain in Azure DNS, you need to create a DNS zone for your domain name. Each DNS record for your domain is then created inside your DNS zone.

## Virtual Network Peering
Vnet peering allows communications between Vnets in the same (regional Vnet peering) or different (global Vnet peering) regions. It allows communications between resources in the peered networks.

One common scnerario is to cofigure an Azure VPN Gateway in a peered network and use that network as a central hub for other peered Vnets. This architecture allows peered Vnets to share resources within the central hub. For example, we can configure an Azure VPN Gateway within the central hub as a transit point. With this central Vnet we won't have to deploy that VNP Gateway in every single peered network.

### Extend peering
There are three methods in extending Vnet peerring: 
- **UDRs -** By configuring user-defined routes, you can specify how traffic should flow between VNets or between subnets within the same VNet. This can include directing traffic through specific gateways or services to reach its destination. In the context of extending peering capabilities, UDRs can be used to direct traffic between VNets that are not directly peered.

- **Hub and Spoke Networks -** The hub and spoke architecture is a network topology where multiple smaller networks (spokes) are connected to a central, larger network (hub). In the context of Azure VNets, this architecture typically involves one central VNet (the hub) connected to multiple VNets (the spokes). By setting up a hub VNet and establishing peering connections between the hub VNet and each spoke VNet (A, B, and C), you create a centralized point for communication between all VNets involved. This allows communication between any spoke VNet and the hub VNet. However, direct communication between spoke VNets (e.g., A to C) typically requires traffic to route through the hub VNet.

The Virtual WAN architecture is a hub and spoke architecture with built-in scale and performance capabilities. See [this documentation](https://learn.microsoft.com/en-us/azure/virtual-wan/virtual-wan-about) for more details. 

- **Service chaining -** Service chaining involves the sequential forwarding of network traffic through a series of network services or appliances. In Azure, this might involve routing traffic through various Azure services, such as firewalls, load balancers, or other network appliances. By configuring service chaining, you can define a path for network traffic to follow as it moves between different VNets or resources within the same VNet. This allows you to apply specific network services or policies to the traffic as it traverses the network.

## Configure network routing and endpoints
It's possible to use network routes to control the flow of traffic through a network. Azure virtual networking provides capabilities to customize the network routes, establish private endpoints, and access private links.

### System routes
Azure uses system routes to direct traffic between virtual machines, on-premise networks, and the internet. The information about system routes are recorded in a route table. 

**Things to know about system routes** 
- System routes can be used to control traffic between virtual machines that are in the same subnet, or different subnets but the same virtual network, and between virtual machines and the internet.
- A route table contains a set of rules about how traffic should be forwarded within a Vnet. Each route table is associated with a subnet. When a packet is leaving a subnet, it gets matched against the associated route table, and if it's not found there, it'll be dopped. 

### User defined routes
User defined routes provide the capability to define custom routes to direct traffic in a Virtual Network. Instead of solely relying of Azure's automatic routing, we can specify a next hop target based on our business requirements. So, it provides a more granular control over how traffic should be routed between different components of the infrastructure.

**Business scenario -** Network Virtual Appliance (NVA) is a virtual machine that performs certain network functions like routing, firewalling, or WAN optimization. Imagine a scnerio where we'd like to forward traffic between a VM at the frondend and a VM at the backend; however, we'd like to perform certain network functions before the traffic reaches the destination; in this case, we can take advantage of a user-defined route to make sure the traffic flows through a VNA as a hop target before reaching the target VM.

#### Important parameters within a route table
- **Address Prefix:** When creating a route table we need to specify something known as the address prefix. This referes to the destination ip address range for which the route within this route table is applied for.
- **Next Hop Type:** Refers to the type of network the traffic should be forwarded to after matching a route in the route table. Possible values are ```Virtual network gateway```, ```Internet```, ```Virtual appliance``` and ```None```.

Imagine a scenario where we'd like to route all outbound communications to the internet to go throught a central VM, then the address prefix for the route we create would equal 0.0.0.0/0, and the next hop type would be internet as well.

In another scenario where we'd like all communications within a Vnet to go through a virtual network appliance, the the address prefix within the route table we create would equal the IP address range of the Vnet, i.e., 10.0.0.0/16, and the next hop type would be virtual appliance.

**NOTE:** For cases where the next hop type is a virtual appliance, we'll have to make sure IP forwarding is enabled on the network inteface of the virtual machine in order to be able to forward the incoming traffic to the destination.

### Service Endpoints
Virtual Network service endpoints provide direct and secure connectivity to Azure services over an optimized route over Azure backbone network. Endpoints allow you to secure your critical Azure service resources to only your virtual networks. Service Endpoints enables private IP addresses in the VNet to reach the endpoint of an Azure service without needing a public IP address on the VNet.
### Private Link
An Azure private link is an Azure service that allows you to access an Azure service from a Vnet through a Private Endpoint.
#### Things to know about Azure Private Link
- Private endpoint is an interface that allows you to connect privately and securely to an Azure service through an Azure Private Link. A private endpoint is a private IP address within your virtual network that serves as an entry point for accessing specific Azure PaaS services.
- When you create a private endpoint for a service, the traffic between your virtual network and the service traverses over the Microsoft backbone network, ensuring that the data never goes over the public internet.
#### Difference between a Service Endpoint and a Private Endpoint
In short, through a private link, we can connect to a target Azure service through a private endpoint, which is a private IP address connecting to the endpoint of your target resource. However, through a service endpoint, all private IP addresses in your Vnet can communicate with a target resource.

Service endpoints extend your virtual network's private address space to Azure services. With service endpoints, access to the Azure service is controlled by the service's firewall rules and virtual network rules. Service endpoints are useful for Azure platform services such as Azure Storage, Azure SQL Database, Azure Cosmos DB, etc., where we'd like to restrict their access to only azure virtual network resources. Private endpoints provide secure and private connectivity to specific Azure services by creating an interface in your virtual network. Private endpoints are suitable for scenarios where you need more secure and private access to Azure services, such as accessing Azure Storage or Azure SQL Database from within your virtual network without going over the public internet.

## Configure Azure Application Gateway
See the learning path to review this section. Review the difference between the load balancer and Azure Application Gateway. Here are some of the most important properties of Azure Application Gateway. See this [doc](https://learn.microsoft.com/en-us/azure/application-gateway/features#multiple-site-hosting) for more details: 
- **Autoscaling:** Application gateway standard_v2 supports scaling up & down based on traffic load patterns. Autoscaling also removes the requirement to choose deployment size or instance count upon provisioning. 
- **Zone redundancy:** Application gateway can span across multiple availability zones offering better fault resiliency.
- **Static VIP:** The standard_v2 SKU of Application Gateway support static virtual IP, and even during potential changes and updates, its VIP remains constant, providing more stability over its networing and routing capabilities.
- **Web Application Firewall:** Azure Application Gateway provides a web application firewall for your web applications. This feature provides a centralized protection for your web applications simplifying security management and maintanence of your backend applications.
- **URL-based routing:** Allows you to route incoming request to the backend servers based on the path of the URL. For example, requests to ```www.example.com/images*``` could be routed to one VM, and requests to ```www.example.com/videos*``` could be routed to another.
- **Multi-site hosting:** With Application Gateway, you can configure routing based on host name or domain name for routing to multiple web applications using the same application gateway. For example, you can configure routing requests to ```http://contoso.com``` to one server, and requests to  ```http://fabrikam.com``` to another.
- **Redirection:** A common scenario for many web application is the automatic support for HTTP to HTTPS redirection to make sure all communications between the application and the client occurs over a an encrypted path. Here are all the redirection capabilities of Azure Application Gateway: 
    - Redirection from one port to another, this allows redirecting from http to https. 
    - Path-based redirection, i.e., redirecting from http to https only on specific site are, like when ```/site/*``` is reached. 
- **Session affinity:** The cookie-based session affinity is useful when a user needs to be routed on a specific backend server for processing.
- **Custom error pages:** Creating custom error pages showing your brand, instead of the default error page.
- **Connection draining:** Help you with graceful removal of backend pool memebers during planned updates or health probe problems.
- **Rewrite HTTP headers and URL**
- **Sizing:** Application gateway standard_vs can be configured for autoscaling and fixed-size deployments.

## Design an IP addressing schema for your Azure deployment
When migrating to the cloud, you need to plan private and public IP addresses so you won't run out of available IP addresses and capacity for future growth in the future. A good IP address scheme provides flexibility, room for growth, and integration with on-premise networks. 
### Integrate Azure with on-premises networks
 Azure networks and on-premises networks should use non-overlapping IP address ranges to ensure proper routing and connectivity. For example, you can use the 10.10.0.0/16 address space for your on-premises network and the 10.20.0.0/16 address space for your Azure network because they don't overlap. But, you can't use 192.168.0.0/16 on your on-premises network and use 192.168.10.0/24 on your Azure virtual network. These ranges both contain the same IP addresses so traffic can't be routed between them.

**NOTE -** For on-premise network, there are three ranges of nonroutable IP addresses that are designed for internal networks that won't be sent over internet routers:

10.0.0.0 to 10.255.255.255: over 16 million unique addresses. It's typically used by larger organizations for their internal networks.

172.16.0.0 to 172.31.255.255: Provides around 1 million unique addresses. It's commonly used by medium to large-sized businesses for internal networks.

192.168.0.0 to 192.168.255.255: Offering over 65,000 unique addresses. It's widely used by home networks, small businesses, and branch offices.

**NOTE -** Remember that Azure uses the first three addresses on each subnet. The subnets' first and last IP addresses also are reserved for protocol conformance. Therefore, the number of possible addresses on an Azure subnet is (2^n)-5, where n represents the number of host bits.

## Distribute your services across Azure virtual networks and integrate them by using virtual network peering
With peered virtual networks, traffic between virtual machines is routed through the Azure network. The traffic uses only private IP addresses. It doesn't rely on internet connectivity, gateways, or encrypted connections. The traffic is always private, and it takes advantage of the high bandwidth and low latency of the Azure backbone network.

### Cross-subscription virtual network peering
You can use virtual network peering even when both virtual networks are in different subscriptions. This setup might be necessary for mergers and acquisitions, or to connect virtual networks in subscriptions that different departments manage. Virtual networks can be in different subscriptions, and the subscriptions can use the same or different Microsoft Entra tenants.

### Transitivity
Virtual network peering is nontransitive. Only virtual networks that are directly peered can communicate with each other. Virtual networks can't communicate with peers of their peers.

### Gateway transit
You can connect to your on-premises network from a peered virtual network if you enable gateways transit from a virtual network that has a VPN gateway. Using gateway transit, you can enable on-premises connectivity without deploying virtual network gateways to all your virtual networks.

This method can reduce the overall cost and complexity of your network. By using virtual network peering with gateway transit, you can configure a single virtual network as a hub network. Connect this hub network to your on-premises datacenter and share its virtual network gateway with peers.

### Overlapping address spaces
IP address spaces of connected networks within Azure, between Azure and your on-premises network can't overlap. This is also true for peered virtual networks. Keep this rule in mind when you're planning your network design. In any networks you connect through virtual network peering, VPN, or ExpressRoute, assign different address spaces that don't overlap.

### Alternative connectivity methods
**ExpressRoute circuit -** Another way to connect Vnets together is through an ExpressRoute Circuit. ExpressRoute is a dedicated, private connection between an on-premise datacenter and an Azure backbone network. Vnets that are connected through an ExpressRoute are part of the same routing domain and can communicate with one another.

**VPN Gateways-** VPNs use internet to connect on-premise data centers to Azure backbone networks through an encrypted tunnel. We can use a site-to-site configuration to connect Azure Vnets through a VPN Gateway. VPN Gateways have higher latency than Vnet peering and cost more.

**Note -** Because it's easy to implement and deploy, and it works well across regions and subscriptions, virtual network peering should be your first choice when you need to integrate Azure virtual networks.

## Host your domain on Azure DNS
When a packet of data needs to be routed through the TCP protocol, a connection is established between the client, i.e., a laptop, to a server, i.e., www.microsoft.com, through the use of IP addresses. In this scenario, how would the client know the IP address of server? In real-world scenarios, a domain name is assigned to the IP address of the machine running an application. The domain name is then communicated to users/clients.

In reality, there are DNS servers available on the internet that map domain names to IP addresses. In the above scenario, the client will access the DNS server on the internet and query the domain name of the server to find its IP address.

### Routing a domain name to a VM
When an application is up & running on a VM hosted in Azure, we have the possibility to assign a domain name to the IP address of that VM. That name will be appended to ```<regionname>.cloudapp.azue.com```. However, we can also buy a domain name from vendors in the market, and make sure all incoming traffic to that domain gets routed to the IP address of the machine running our application. We can do so by adding a record to the DNS server provided by the vendor. There are a number of different records available, but the most common one is the "A" record, but in each one we will have to provide the IP address of the server running our application.

### Azure DNS
Azure DNS allows you to host and manage your domains by using a globally distributed name-server infrastructure. 

## Azure DNS Zone
Here you'd create a zone that maps onto the public domain already bought, and instead of creating the records within the external service provider, it'd be possible to create it within the Azure platform. This allows us to manage the domain fully within Azure. 

## Different records 
There are a vareity of record types we can add into the Azure Zone service: 

**Record A -** It's the most simple record type, also known as the "Address" record, that maps a domain name into the IPv4 address of the server running that domain's service. 

**Record NS -** Name Servers are responsible for providing results for queries by the DNS resolver for a specific domain. When a DNS resolver makes a query, it first checks the Name Server for that domain. Once the NS is found, it queries the NS to find the necessary information for that domain in question, i.e., the A records to find the IP address mapped to it.

**Record CNAME -** It's used to create an alias from one domain to another. If we had multiple domain names accessing the same web server, we'd use CNAME. 

**MX -** It's a mail exchange record. It maps mail requests to mail servers. 

**TXT -** It's a text record. It maps text strings to domain names; Azure and Microsoft 365 use TXT records to verify domain ownership.

**NOTE -** You can use Azure aliases to override the static A/AAAA/CNAME record to provide a dynamic reference to your resources. It'd be useful to point a hostname to an Azure resource, like a load balancer, instead of pointing it to a single IP address; in this case the domain name would continue to work if the load balancer's ip address changes. 

## Identify routing capabilities of an Azure virtual network
Allows us to control traffic within a Vnet. Through the use of Microsoft-managed system routes, communications between VMs are possible across subnets, Vnets and on-premise networks. However, it is possible to override these system routes by defining custom routes to control the flow to the next hop.

### System routes
By default, there are two system routes by default that allow communications between subnets and the internet, however, additional system routes get created if the following capabilities are enabled.

- **Vnet peering**
- **Service chaining**
- **Virtual Network gateway -** We can use a virtual network gateway to send encrypted traffic between Azure and on-premises, or to send encrypted traffic between Azure networks. A virtual network gateway contains routing tables and gateway services.
- **Virtual network service endpoint -** Virtual network service endpoints extend your private address space in Azure by providing a direct connection to your target resources, i.e., a storage account; so your Azure VMs can access this storage account; on the other hand accesss to this storage account by public VMs is blocked and it's only accessible through IP exceptions and firewall openings. As you enable service endpoints, Azure creates routes in the route table to direct this traffic.
### Custom routes 
We can use custom routes to override the default systems routes and control the flow of traffic to the next hop. The next hop can be of type:
- Virtual appliance: It can be an Azure firewall, a virtual machine to even an Azure load balancer. So, it'd be possible to route incoming traffic to a load balancer, or an Azure firewall to perform certain security functions before reaching the target destination. We would also need to provide the IP address attached to the next hop. 
- Virtual Network gateway
- Virtual Network: Use to override the default system route within a virtual network.
- Internet: Use to route traffic to a specified address prefix that is routed to the internet
- None: Use to drop traffic to a specified address prefix. 
#### Service tags for UDFs
You can define service tags as the address prefix for a UDF. A service tag represents a group of IP address prefixes from a given Azure service. So, Microsoft automatically updates the service tag in case an address prefix changes and we won't have to create a high number of UDFs for each IP address.  
### Boarder gateway protocol
Your network gateway in your on-premise network can exchange routes with your virtual network gateway in Azure by using a boarder gateway protocol. Read more details here in the [documentation](https://learn.microsoft.com/en-us/training/modules/control-network-traffic-flow-with-routes/2-azure-virtual-network-route). 

### route selection and priority
If there are multiple routes with the same address prefix, Azure selects the route based on the type in the following order of priority:
- User-defined routes
- BGP routes
- System routes

## Improve application scalability and resiliency by using Azure Load Balancer
With Azure Load Balancer you can distribute incoming traffic to multiple virtual machines in the backend to scale your application; imaging a healthcare organization that has a website at the front end for patients to book an appoitment. It's absolutely vital for the website to properly manage a large number of requests to the front end, so that the patients can always book an appointment. If there are multiple servers at the backend, Azure Load Balancer can distribute the traffic to mutliple servers in parallel leading to improved ***capacity***, and it can monitor the heath of those servers and route the traffic to healthy ones in case a failure occuers leading to improved ***resiliency***. 

Another important feature of load balancers is that they use a hash-based algorithm for distributing the traffic to the backend VMs. They usse a five-tuple hash for it. The hash is created based on the below five elements. Read more about the distribution algorithm [here](https://learn.microsoft.com/en-us/training/modules/improve-app-scalability-resiliency-with-load-balancer/3-public-load-balancer) in the documentation:
- ***Source IP address -*** The IP address of the requesting client
- ***Source port -*** The port of the requesting client 
- ***Destinatioin -*** IP: The destination IP of the requesting client
- ***Protocol type -*** The specified protocol type, TCP or UDP

Also, there are two tiers for ALB; read in more details in [this](https://learn.microsoft.com/en-us/training/modules/improve-app-scalability-resiliency-with-load-balancer/2-load-balancer-features) documentation.

**NOTE:** For basic load balancers, VMs need to be part of the same availability set or availability zone to be able to be accommodated into the backend pool. 

### Internal load balancer
In addition to forwarding traffic from users to the front-end servers, you can use Azure Load Balancer to forward traffic from front-end servers evenly to the backend servers. In some applications, the frontend calls for business logic in servers hosted in the middle tier. You'd want to make sure the middle tier is also as scalable and resilient as the middle tier; in order to do so, we can use an internal load balancer. See [this](https://learn.microsoft.com/en-us/training/modules/improve-app-scalability-resiliency-with-load-balancer/5-internal-load-balancer) page to read more on an interesting scenario where internal load balancers are very useful.

## Point to site VPN connection
Point to site VPN connections allow you to establish a connection between Azure Virtual Network and client machines. Imagine a scenario where we'd like to establish a connection between a client machine and a web application running on a Virtual Machine in an Azure Virtual Network. Normally, such connection is not possible, since no public IP is assined to this Virtual Machine. In such cases, we can use something known as Point to site VPN connection. Here are the required steps to implement this solution on a high level: 
- Create an Virtual Private Network Gateway resource and attach it to the virtual network hosting the VM
- Create an empty Gateway subnet to host the VMs that are responsible for the routing of traffic between client machines and the VMs in the Virtual Network.
- In order to connect the client machines from the internet onto the VNet through the VPN Gateway, there should be a sort of authentication mechanism in place. One way for clients machines to authenticate into the Vnet is through certifications. So, there should be a certificate in place in the client machine for the Vnet to recognize. See the Microsoft [documentation](https://learn.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-certificates-point-to-site) on how we can generate a certification for authentication.

Once a VPN connection has been properly established, we would be able to log into the application running on a VM in the Vnet directly from our machine. P2S VPN is also a useful solution to use instead of S2S VPN when you have only a few clients that need to connect to a VNet.

## Site to site VPN connection
There are certain scenarios where we would like to connect an entire on-premises network, i.e., client machines, servers, to the workloads in the Vnet. For such scenarios, we can make use of site-to-site VPN connection. Here are the requirements for establising a site-to-site VPN connection.

- On the on-premise side, you need to have a VPN device that can route traffic via the Internet onto the VPN gateway in Azure. The VPN device can be a hardware device like a Cisco router or a software device ( e.g Windows Server 2016 running Routing and Remote services). The VPN device needs to have a publically routable IP address.
- The subnets in your on-premise network must not overlap with the subnets in your Azure virtual network.
- The Site-to-Site VPN connection uses an IPSec tunnel to encrypt the traffic.
- The VPN gateway resource you create in Azure is used to route encrypted traffic between your on-premise data center and your Azure virtual network.
- There are different SKU's for the Azure VPN gateway service. Each SKU has a different pricing and attributes associated with it. See the [doc](https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-about-vpn-gateway-settings). 

**NOTE -** Site-to-site VPNs use IPSEC to provide a secure connection between your corporate VPN gateway and Azure.

Here are the required steps for creating a site-to-site VPN conneciton in Azure: 
- Create a gateway s
- Create a local network gateway
- Create a virtual network gateway
- Create the VPN connection

## Azure Virtual WAN
There are certain scenarios where we would like to connect a range of on-premise infrastructure, i.e., office branches, to multiple Vnets in Azure. One way to tackle this is to use a VPN Gateway to establish a connection between an on-premise resource to a Vnet, and establish a Vnet peeting to the second Vnet. This is due to the fact that VPN Gateways can only establish a connection to maximum one Azure Vnet. 

For such scenarios where there are a high number of Azure Vnets and a high number of office locations, we can make use of Azure Virtual WAN. In kind of a mesh network, you can connect your multiple virtual networks onto the WAN. Here's how to simulate a scenario for Azure Virtual WAN:
- Create two Vnets each hosting a VM that have IIS installed on them. These Vnets have no peerings between them.
- Deploy an Azure Virtual WAN resource.
- Deploy a virtual Hub, which is a Vnet used for the Azure Virtual WAN.
- Next step would be to connect our Vnets to the virtual hub.

# Deploy and manage Azure Compute Resources
The primary advantage of working with virtual machines is to have more control over installed software and configuration settings. Azure Virtual Machines supports more granular control than other Azure services, such as Azure App Service or Azure Cloud Services.

## Virtual Machine
Imagine a scenario where we'd like to deploy a web application; for this, we would need servers to host the application, we would also need storage to store data associated with the application, and we also need networking; so, all the physical servers need to be part of a network.

Within Azure, we can take advantage of Cloud Computing concepts and provision a Virtual Machine in the cloud. In addition to the virtual machine, you will see other resources that get created as part of the virtual machine resource, such as the network interface, the disk, network security group, and the virtual network. Let's dive deeper into each components of our network resources:

**VM Availability sets -** Availability set is a logical grouping of the virtual machines. It helps to improve the overall availability of the virtual machines. The VMs are hosted on a physical server in a data center. And if all the VMs hosting the application are within one single physical server, then the whole application might go down in case of failure or maintenance on that data center. In order to handle such a scnenario, we can make the VMs as part of an availability set. When we assign a virtual machine as part of an availability set, it gets assgined a ***fault*** and ***update*** domain. Update domain means that Azure will apply updates on the underlying infrastructure one domain at a time, and fault domain means that the VMs gets assigned to different power source and network domains. This ensures that VMs that are part of the same availability set are always available in case an update is required on the physical infrastructure or the power source and network has to be reset. For more details on availability sets and things to consider when using them, see [this documentation](https://learn.microsoft.com/en-us/training/modules/configure-virtual-machine-availability/3-setup-availability-sets).

**NOTE -** In a proper design we need to separate application tiers, meaning that there VMs each in tier should have their own availability set. Each fault domain however, contains one vm from each tier. So, in case of a power outage or network issue, the whole application remains up & running.

**VM Availability zones -** This feature helps provide better availability for your application by protecting them from datacenter failures. Each Availability zone is a unique physical location in an Azure region. Each zone comprises of one or more data centers that has independent power, cooling, and networking. Using Availability Zones, you can be guaranteed an availability of 99.99% for your virtual machines. You need to ensure that you have 2 or more virtual machines running across multiple availability zones.

**VM scale set -** One way to create an identical set of Virtual Machines to host an application is through the VM scale set. Instead of manually creating virtual machines to host the application, we can create a scale set resource that is responsible for creating the virtual machines and scaling the application in a horizontal way. Using this service, we can define rules for scaling, i.e., if CPU percentage of the initial VM reaches 75 due to additional load on that VM, go ahead and create an additional VM for horizontal scaling. The other way around is possible. Using this feature, it is possible to scale down the number of VMs. For more details, see the microsoft [documentation](https://learn.microsoft.com/en-us/azure/virtual-machine-scale-sets/overview). 

**Site Recovery service -** Site Recovery helps ensure business continuity by keeping business apps and workloads running during outages. Site Recovery replicates workloads running on physical and virtual machines (VMs) from a primary site to a secondary location. When an outage occurs at your primary site, you fail over to a secondary location, and access apps from there. After the primary location is running again, you can fail back to it.

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
Many organizations prefer to use their own managed keys for encryption of disks attached to their Virtual Machine. Here's how we make sure the Azure managed disk is encrypted through customer managed encryption:
- Once a key vault is created and in place, go ahead and create a [key vault key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_key)
- Create a [key vault encyption set](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/disk_encryption_set) within the above key vault key.
- Make sure the key vault encyption set has the required access to the key vault through the key vault access policies.
- Attach the encryption set to the Azure managed disk 
- And finally, attach the Azure manage disk to the virtual machine

### Stopping/de-allocating vs Restarting a VM
When a VM is restarted, data within all OS disk, managed disk, and temporary disk will be intact; however, when a VM is stopped/deallocated, the data within the temporary disk is lost, but the data within OS and managed disk will still remain intact.

### Deploying an Azure KeyVault
For security reasons, we've used network access control lists within the Key Vault block in Terraform to only give access to Azure resources within a subnet. So, normally, all resources within a subnet would be able to communicate to the Key Vault. Before doing so, we need to specify in the subnet that it should have a service endpoint for the key vault. This ensures that resources within that subnet can communicate with the key vault securely without exposing traffic to the internet.

# Configure and manage virtual networking
In the prior section when taking about VMs, we had a quick introduction about certain networking aspects in Azure. Here we'll dive deeper into azure networking resources and concepts.

## Azure Bastion
It's a service provided by Azure that allows secure RDP and SSH access to VMs within a Virtual Network. It acts as a gateway.

## Configure Azure App Service plans 
Previously we discussed Virtual Machines, which give un a fine-grained control over the software configurations, installations etc. Using Azure App Service, the underlying compute infrastructure is abstracted away and is completely managed by Microsoft. Within an Azure App Service, we need to provision and define an Azure App Service Plan that defines the required compute infrastructure to run the application. One or more applications can be configured to run on the same Azure Service Plan. Multiple applications in the same plan share the same virtual machine instances. However, if the application is resource-intensive, with different scaling requirements or is supposed to be deployed in a different regiion, it's best to add it to a new service plan.

### Plans and pricing
We can configure a free, shared, basic, standard, premium, and isolated plan each suitable for a different kind of use case; read [this](https://learn.microsoft.com/en-us/training/modules/configure-app-service-plans/3-determine-plan-pricing) page for more details.

## Configure Azure App Service
### Web App Logging
There are different logging capabilities in Azure Web App:
- **Application loggings:** This captures log messages that are generated by the application code. This can be at the filesystem level or blob storage level. filesystem level are for temporary purposes and are automatically turned off after 12 hours, but blob is the more permanent solution written into storage account. We can also enable Azure Monitor to stream these logs into Azure Event Hub, Azure Storage or Log Analytics.
- **Web Server logging:** This records information about incomming HTTP requests, and outgoing responses. This includes data like requested URL, response status, client IP address and response size. 
- **Detailed error messages:** This logging option allows you to capture detailed error messages generated by the web server. It includes stack traces and other diagnostic information that can help troubleshoot issues with your web app. Detailed error messages are particularly useful during development and testing phases to quickly identify and fix bugs.
- **Deployment logging:** Information recorded when changes are published to the web application.
- **Failed request loggin:** Help log information about failed HTTP requests helping to diagnose performance issues in your application.
- **NOTE -** It is possible to tacking http request to the web app through a live stream logging capability of Azure Web App. 

###  Deployment slots: 
Deployment slots are live apps that have their own hostnames. They're only available via the standard, premium and isolated app servive tiers. App content and configuration elements can be swapped between the deployment slots, including the production slot.
Advantages in using deployment slots:
- Validation: We can deploy changes into a staging slot before swapping them with the production slot. This is a more efficient approach than having multiple Azure Web App for each environment. 
- Restoring to the last version: if the new version is not as we expected, we can perform the reverse swapp to return to the previous version
- Auto swap: Similar to automations in Azure DevOps, when auto-swap is enabled, whenever we push the new changes to a slot, it'll automatically get swaapped with the production slot.
Security features in Azure App service: 
- When you enable the security module in Azure App Service, every incoming request/traffic will pass through this module before it's handled by your application
- So, the authorization and authentication security module in Azure App Service runs in the same environment as the application code, but separately

**Backup for the application**
- The Backup and Restore feature in Azure App Service lets you easily create backups manually or on a schedule. You can configure the backups to be retained for a specific or indefinite amount of time. You can restore your app or site to a snapshot of a previous state by overwriting the existing content or restoring to another app or site.
You would need a storage account and a container as the destination for the backup files. If the storage account is configured for a firewall, cannot use it as the destination for the backup files. 
### Monitoring applications 
We can use Azure Application Insight, which is a feature of Azure Monitor for monitoring and detecting any performance anomolies in your live applications. We can use it to monitor incoming requests, frontend application and backend services running in the backgroun. See [this](https://learn.microsoft.com/en-us/training/modules/configure-azure-app-services/10-use-application-insights) documentation for more details on how application insight can be integrated for monitoring different elements of the application. 

## Azure container instance
- A container in Docker is a standalone package that contains everything you need to run a piece of software. - A container package includes application codes, the runtime environment, such as .Net Core, tooks, settings and dependencies. 

- A **Dockerfile** is a text file that includes instructions on how to build a Docker image. 
- The key feature of Docker is that it guarantees that a containerized package runs the same way locally, on windows, linux or in the cloud. 
- Once your code is contanerized, tested and deployed in the cloud, you can use Azure Container Instances for easily scaling it. 

### VMs vs Containers
- They run the user mode portion of an operating system, tailored to contain only necessary services for applications, thus consuming fewer system resources. Virtual machines run a complete operating system, including the kernel, which requires more system resources.
- Deployment methods and storage solutions also differ between the two, with containers using Azure Disks or Azure Files for storage and virtual machines utilizing virtual hard disks or SMB file shares.
- Additionally, fault tolerance mechanisms vary, with containers rapidly recreated by orchestrators in case of node failure, while virtual machines can fail over to another server within a cluster. When considering container adoption, benefits such as increased flexibility, speed in development and deployment, simplified testing, and higher workload density should be taken into account for optimal implementation of containerized applications within a company's infrastructure.

### Container groups
Multi-container groups are useful when you want to divide a single functional task into a few container images. The images can be delivered by different teams and have separate resource requirements. Containers in a group can use Azure file shares as volume mounts. Each container in the group mounts one of the file shares locally.

## Azure Kubernetes cluster
AKS is a fully managed Kubernetes service provided by Azure. It simplifies the deployment, management, and scaling of Kubernetes clusters in Azure. AKS integrates seamlessly with other Azure services, making it easy to deploy containerized applications on Azure. For more details, see [this](https://learn.microsoft.com/en-us/azure/aks/what-is-aks) doc.
### Kubernetes Components
- **Master Node:** The master node is responsible for managing the Kubernetes cluster. It includes several components:
 - API Server: Exposes the Kubernetes API, which allows users to interact with the cluster.
 - Controller Manager: Manages various controllers that handle cluster-wide tasks, such as node management, pod replication, and endpoint creation.
 - Scheduler: Assigns pods to nodes based on resource availability and scheduling constraints.
 - etcd: A distributed key-value store that stores cluster configuration and state.
- **Worker Nodes:** Worker nodes are the machines where containers are deployed and executed. They consist of several components:
 - kubelet: An agent that runs on each node and communicates with the Kubernetes master node. It manages containers, pod lifecycle, and node resources.
 - kube-proxy: Maintains network rules on nodes. It enables communication between pods and external network clients.
 - Container Runtime: The software responsible for running containers, such as Docker or containerd.
- **Pod** 
 - A pod is the smallest deployable unit in Kubernetes and represents one or more containers that are tightly coupled and share resources, such as networking and storage.
 - Containers within a pod share the same network namespace, IP address, and port space, allowing them to communicate with each other via localhost.
 - Pods are ephemeral by nature, meaning they can be created, destroyed, or replicated dynamically based on the workload requirements.
 - Common examples of pod usage include deploying a single-container application or deploying multiple containers that need to work together, such as a web server and a sidecar container for logging.
### kubelet within Azure Kubernetes
The Kubelet is a critical component of a Kubernetes node responsible for managing containers and their associated pods. It ensures that containers are running as expected on the node by interacting with the Kubernetes API server and performing actions based on the desired state specified in the pod. Here are its most important functionalities:
- **Container Lifecycle Management:** The Kubelet manages the lifecycle of containers on the node, including starting, stopping, and restarting containers as needed.
- **Pod Lifecycle Management:** It ensures that pods are running and healthy on the node, and it handles pod scheduling, initialization, and cleanup.
- **Resource Management:** The Kubelet monitors and manages node resources (CPU, memory, etc.) to ensure that containers and pods are allocated resources as specified in their resource requests and limits.
- **Networking and Storage:** It sets up networking and storage configurations for containers and pods, including configuring network interfaces and mounting storage volumes.

# Implement and manage storage in Azure
## Storage account types
Below we can see an overview of Azure Storage account types. See [this documentation](https://learn.microsoft.com/en-us/azure/storage/common/storage-account-overview) for an overview of storage types.
- **Standard general-purpose V2:** Has support for blob storage, table storage, queue storage and table storage. Has support for all redundancy options.
- **Premium block blobs:** Has only support blob storage and is suitable for scenarios with high transactions rates and low-latency requirements for blobs.
- **Premium file shares:** Premium account for Azure Files only and supports LRS and ZRS redundancies. Suitable for enterprise and high-performing scale applications with support for SMB and NFS file shares.
- **Premium page blobk:** Premium account for page blobs and is used for storing hard disks attached to VMs. 

**Things to note:** 
- 2 ZRS, GZRS, and RA-GZRS are available only for standard general-purpose v2, premium block blobs, premium file shares, and premium page blobs accounts in certain regions.
- 3 Premium performance storage accounts use solid-state drives (SSDs) for low latency and high throughput.
- The premium account for block blobs and file shares does not have support for access tiers (cool, hot and archive).
- The premium accounts are mor suitable for high-transaction and low-latency applications like streaming and machine learning. Here the storage costs are higher but transactions costs are cheaper.

## Implement Azure Storage Account
Azure Storage offers a scalable object store for data objects. It provides a file system service in the cloud, a messaging store, and a NoSql object store. Developers can use Azure Storage for working data. Working data includes websites, mobile applications and desktop applications. Azure Storage can be used to store 3 categories of data: 
- VM data: VM data include Disks and Files; disks are storage blocks for VMs and files are fully-managed file shares in the cloud.
- Structured data: Unstructured data can be stored in Azure Blob Storage or Azure Data Lake Storage; Azure Blob Storage is a highly scalable, REST-based cloud storage object. Azure Data Lake Storage is a Hadoop Distributed File System.
- Unstructured data: Structured data can be stored in Azure Table Storage, Azure Cosmos DB, and Azure SQL. Azure Cosmos DB is a globally distributed database service, and Azure SQL is a database-as-a-service database based on SQL.
### Storage Account Tiers
- Standard: Offers a hard drive disk and offers the cheapest option per GB
- Premium: Offers a solid state drive with enhanced peformance with low-latency suitable for VM disks with I/O intensive applications like databases.

### Storage solutions by Azure storage account
There are 4 data services that can be accessed using Azure Storage Account: Azure Blob Storage, Azure Queue, Azure Files, Azure Table Storage. See the details for all these data services [here](https://learn.microsoft.com/en-us/training/modules/configure-storage-accounts/3-explore-azure-storage-services) in the documentation.

### Replication strategies
Azure creates multiple copies of your data to protect it again planned or unplanned events like transient harware failures, power outage, natrual disasters etc. See below for the types of redundancy solution and see the [documentation](https://learn.microsoft.com/en-us/azure/storage/common/storage-redundancy) for more in-depth information.
- **Locally redundant storage (LRS)** copies your data synchronously three times within a single physical location in the primary region. LRS is the least expensive replication option, but isn't recommended for applications requiring high availability or durability. An example scenario where the LRS storage type should be chosen is where we're processing sensor data in real-time and we're only interested in the most recent version and data loss is not important.
- **Zone-redundant storage (ZRS)** copies your data in 3 availability zones within the primary region. For high availability applications, Microsoft recommends using ZRS, but also replicating to a secondary region.
- **Geo-redundant storage (GRS)** copies your data 3 times in a single physical location in the primary region using LRS, but also to a physical location in a seconday region.
- **Geo-zone-redundant storage (GZRS)** copies your data into 3 availability zones in the primary region using ZRS, but also into a single physical location in a secondary region using LRS.

#### Read access to data in the secondary region
In your storage account for GRS or GZRS, the data in the secondary region is not accessible, unless a failover occurs. For applications with requirements for high availability, you can configure your storage account for read access in the seconday region. When this is enabled on your storage account, you can always read from the seconday regions, including cases where the primary region is unavailable. Read-access geo-redundant storage (RA-GRS) or read-access geo-zone-redundant storage (RA-GZRS) configurations permit read access to the secondary region.

When your storage account is set for RA-GRS or RA-GZRS, your application can read from the secondary endpoint as well as the primary endpoint. The advantage for this storage mode is that you can test your application in advance to make sure that it can indeed read from the seconday region.

[See the documentation](https://learn.microsoft.com/en-us/azure/storage/common/storage-redundancy#read-access-to-data-in-the-secondary-region) for more details. 

### Secure storage endpoints
You can use Azure service endpoints to restrict access to a storage account to only resources within a Vnet or Subset. An Azure Service Endpoint will extend a Vnet's IP address range by incorporating that storage account into its space. This way, access to the storage account will be possible through IP Address exception and firewall openings.

Another approach to securing the storage account would be to create a private link to resources within a Vnet. So, the advantage to this approach is that communications between resources in a Vnet/Subnet to this storage account is established through the Microsoft backbone network infrastructure and won't go through the public internet. See [this] (https://www.youtube.com/watch?v=vM7yDwHSc_o) video for more details on how to create a private link to an Azure Storage Account.

## Configure Azure Blob Storage
It's a service for storing large amounts of unstructured data; data that does not adhere to any model or definition.
### Blob Access Tiers
There are 3 access tiers for blob data, Hot, Cool & Archive. Each one is optimized for a specific pattern of data usage.
- **Hot -** The Hot tier is designed for the frequent read and write of objects in the storage account. By default, SAs are created in the HOT tier; it has the lowest access costs and highest storage cost.
- **Cool -** This tier is designed for storing large amounts of objects that are infrequently accessed. Data must remain untouched for at least 30 days for this tier. A example use case would be short-term backup files and disaster recovery datasets. It's a cost-effective option for data storage and more expensive than the hot tier for accessing data. 
- **Archive -** It's an offline tier for storing data and is optimized for use cases that can tolerate hours of latency. Data must remain in the storage account for at least 180 days otherwise will be subject to early deletion charges. It's the most cost-effective option for storing data and the most expensive for accessing it. Data for the Archive tier includes secondary backups, original raw data, and legally required compliance information.

**NOTE:** The hot and cool tiers can be set at the storage account level, but the archive mode can only be set at the blob level.

### Lifecycle management rules
Azure blob storage supports lifecycle management rules; we can use it to transition to the right access tier automatically based on certain rules. We can do so using Terraform. See [this documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_management_policy).

### Object Replication for block blobs
Object replication for block blobs is a feature that allows you to copy your blobs asynchronously between a source storage account and the destination storage account. Here are a few scenarios where this could be useful: 
- Minimizing read requests by allowing clients to read from the region that's closer to them.
- After your data has been replicated, you can reduce costs by setting it the archive tier automatically using life cycle management policies.
- You can optimize your data distribution by analyzing it in single region and replicating the result to additional region.

**Things to know about Object Replication**
- You can define rules to specify which objects should be replicated from source to the storage account.
- This feature is only available for standard general-purpose V2 and premium block blob storage accounts.
- Blob versioning should be enabled on both the source and destination storage accounts.
- Change feed should also be enabled on the source storage account.

### Identity-based authentication to Azure Files using SMB
Here are the following methods to authenticate into Azure Files. See [this documentation](https://learn.microsoft.com/en-us/azure/storage/files/storage-files-active-directory-overview) for more details:
- On-premise active directory domain services authentication
- Entral ID domain services authentication
- Entra ID for Kerberes for hybrid identities
- AD Kerberes authentication for Linux Clients

### Copy Data in Azure Storage Account
Here are the different services for copying data in Azure SA:

**Azure import/export service**
- Used for copying a large amount of data to Azure Blob Storage or Azure Files
- It also allows copying data from Azure Blob Storage to your on-premises environments.
- This is established by the use of disk drives. You can use your own or that of Microsoft
- Once an import (process of copying data into Azure Blob Storage) process, you can opt for a Disk Drive by Microsft. You can then copy the data into that disk drive by creating a job via the Azure portal.
- The copy process is established by the use of the WAImportExportTool. It helps with the following: 
    - It helps to prepares the disk drive and copy data to it during the import process
    - It encrypts the data on the drive
    - It generates journal files that are used during import creation 
    - Helps to identify the number of disks required for the import

**Azure Data Box**
- Helps to copy terabytes of data in and out of Azure without using any internet connection
- This box can be ordered via the Azure Portal

**AzCopy command in Azure Storage Account**
It's a command-line utility to copy blobs or files to or from Azure Storage Account. Use the ```AzCopy make``` command to created a container and the ```AzCopy copy``` command to copy to or download from a Storage Account. In order to authenticate into the Storage Account and run these commands, we'll need a Shared Access Signature (SAS) Token.

### Blob snapshots and versioning
- Snapshot is a read-only version of a blob taken at a point in time. For each blob you can choose to take a snapshot and promote it if necessary to overwrite the current version.
- You can also enable versioning on your blobs and keep track of different versions of the same blob. You can also choose to make a specific version the current version. In some cases, versioning is more practical than taking a snapshot.

### Security in Azure Storage Accounts 
Normally, your storage accounts are a public service accessible through access keys, SAS tokens or Entra ID authentications. However, we can choose to enable something known as a service endpoint on the storage account and make it accessible only through a specific subnet within a Virtual Network. This way, the SA is only accessible through firewall openings and IP exceptions. Follow the below steps to do so: 
- Under the networking tab in your vnet, enable the ```Microsoft.Storage``` endpoint and choose the subnet within the Vnet.
- On your storage account, under the networking tab select "accessible through specific Vnets" and choose an existing Vnet.

The second approach is to use a Private Endpoint to make the storage account accessible to resources within a Vnet. Here we dedicate the Azure service (in this case a storage account) a private IP address from the address range in the Vnet and bring the service into the Vnet.

### Azure File Sync
A service that allows us to store files in a highly durable storage service and be able to access them directly on your on-premise servers. Here are the required steps to implement Azure file sync:
- Create an azure file sync resource
- Within the file sync resource, create a sync group, within which we specify the name of the storage account and the file share within it. This connects the azure file share to the azure file sync and create a **cloud endpoint** 
- Install an Azure File Sync agent on your servers; this allows the servers to connect to the Azure File Sync resource. Once the servers have been registered, they will be shown under the *registered servers* section of the Azure File sync resource. 
- Under the sync groups tab, created a **server endpoint** using the registered servers in the previous step. Here we need to specify the path within the on-premise server where we'd like the sync to take place.

**NOTE:** We can have as many on-premise servers as required for a single cloud endpoint within a sync group. This way all servers connected to the Azure File Sync service will be synced together and share files. The goal is to have a distributed file system here. We are not supposed to upload any file in the file share in the cloud as it will not be projected into the local servers.

# Manage identities and governance in Azure
## Configure Microsoft Entra ID
Microsoft Entra ID is a cloud-based identity and access management service. See [this](https://learn.microsoft.com/en-us/training/modules/configure-azure-active-directory/2-describe-benefits-features) documentation for details on its capabilities.

## Configure role-based access control
We can use role-based access control to ensure resources are protected, but also certain users can access them. So, we can create roles and assign them to different users allowing them to have limited access to certain resources. So with this, we can decide and manage who can access to Azure resouces. We can also control what operations those users can do on Azure resources. Here are certain important concepts to learn:
- Security Principal: An object that can request access to a resource: User, group, service principal, and managed identity
- Role definition: Lists allowed operations on Azure resources; there are build-in roles, but each organization can create their own custom roles.
- Scope: This specifies the boundary for the requested level of access, i.e., subscription, resource group, resource
- Role Assignment: A role assignment attaches a role definition to a security principal at a particular scope.
We also need to explore the difference between RBAC and Entra Id roles.

### Things to consider and about RBAC
- Using RBAC, we can use bulilt-in role definitions, but also create our own custom roles to assign to users and create a fine-grained access to users.
- When definint roles, we define *NotActions*  anc *Actions* to define the operations that are embedded in this role.
- We can also specify *AssignableScopes* to determine on what level this role can be assigned to, i.e., subscriptions, resource groups or resource.
- The most important built-in roles are *owner*, *contributor* & *Reader*. See [this documentation](https://learn.microsoft.com/en-us/training/modules/configure-role-based-access-control/3-create-role-definition) to see what kind of operations each entail.
- A resource inherits role assignments from its parent resource, i.e., a role at a resource group level would automatically be transfered to a resource in it.

**NOTE -** In addition to RBAC, Microsoft Entra Id provides built-in administrator roles to manage Microsoft Entra resources like users, groups and domains.

### Difference between RBAC and Microsoft Entra ID
**Access management -** RBAC controls access to Azure resource, so it provides a more granular access management for Azure resources, but Microsoft Entra provides access to Microsoft Entra resources.
**Scope assignment -** RBAC can assign roles at difference scope, but Microsoft Entra ID provides access at the tenant level.
**Roles -** RBAC has built-in roles and has the possiblity to create custom roles as well, but Entra ID offers administrator roles to manage Entra ID resoureces with the possiblity of creating custom roles, for which we'll need a premium P1 or P2 tier for Entra ID. Here's Microsoft Entra Id administrator roles: *Global admin*, *Application admin*, and *Application developer*.

## Create Azure users and groups in Microsoft Entra ID
Imagine a scenario where you're a Microsoft Entra ID global administrator. A new team of developers are to be onboarded to develop and host an application in Azure. There are a number of external users who are to be consulted for the application design. Here's the goal:
- The goal is to create external users in Microsoft Entra ID for external users.
- We should also create groups to manage access to the application resource

There are 3 ways we can assign roles to users:
- Direct assignment
- Group assignment
- Rule-based assignment

### Dynamic Groups
Using this feature, we can define rules to automatically add users to a group. For this feature, we need to have at leat the premium P1 tier for the Entra ID. When creating a dynamic group, the membership should be of type "dynamic user". Within the group definition, we will have to define dynamic queries to define rules to automatically assign users to that group, i.e., based on the user's properties.

## Custom domains in Entra ID
It's possible to register your custom domains for your defined users in Entra ID. This way the principal names for every new created user will use your custom domain name in Microsoft Entra ID.

## Joining a device to Microsoft Entra ID
In the same way we manage the users and groups and roles in Entra ID, we can also register and manage our devices in Microsoft Entra ID. Same way we created dynamic groups for the users, we can create dynamic groups for devices to allocate devices to groups based on specific rules.

## Self-service password reset
- A feature that's available with an Entra ID of at least premium P1. Within Entra ID unders the "password reset" section, you can enable this option for all or a selected number of users. 
- In order for the password reset option to be enabled for a user, a premium-based licence has to be given to the user
- In order for a password reset to take place, a kind of authentication needs to be in place. We can choose the minimum number of authentications required for a password reset
- Here are the type of authentications supported for password reset: *mobile app notification*, *mobile app code*, *mobile number*, *office number*, *security questions*, and *email*.

## Bulk operations in Entra ID
Instead of creating users one by one, we can take advantage of the bulk operation feature in Entra ID to create, invite, or delete users in bulk. This way we'll need to download a CSV file and add users into it and upload it again to create users in bulk.

## Multi-factor Authenticatioin in Entra ID
For users with strong administrative priviledges, i.e., gloabl Entral ID administrators, we need to make sure their account is 100 % and we would want to enable a feature called multi-factor authentication and add an additional authentication step for the Entra ID account.

Under the MFA page for users, we can see for which user this feature is *disabled*, *enabled*, or *enforced*(the user has set the additional authentication and security mechanism).

## Conditional Access Policy in Entra ID
Conditional Access Policy is a feature of Microsoft Entra ID that allows organizations to control access to Microsoft Resources based on certain signals such as, user or group memebership, IP address or location, device type, the device platform (windows, macOs, Android, Linux etc.) or the user risk level. Conditional access policy is an if-else statements to control access based on these signals. This feature is only available within the premium version of Microsoft Entra ID.

We can implement conditional access policy in Entra ID under the security tab, and then conditional access policy. We can choose to enable this feature for all, or a selected number of users or groups. Within this feature, we can also choose the application for which conditional access policy is enabled, i.e., Microsoft Azure Management, which is associated to the Azure Portal.

If the conditional access policy detects any risk based on the above signals, we can choose to block, or provide a conditional access that requires an additional step, like the device being compliant, or multi-factor authentications. See a list of all possible steps [here in the documentation](https://learn.microsoft.com/en-us/entra/identity/conditional-access/overview).

## Administrative Units in Entra ID
In cases where there are multiple departments in an organization, it would make sense to isolate the management of users, groups and other Entra ID resources for each department. So, each department would be assicuated to an administrative unit with restricted administrative role over that portion of the organization.

## Resource Tags
Here's the benefit of using tags:
- **Resource management:** The IT teams needs to quickly spot resources in certain environments, ownership groups and other properties. Tags are useful for access and role managements.
- **cost management and optimization:** Making business groups aware of the cost of cloud resource is important in undestanding consumptions of certain workloads.
- **Governance and compliance:** Maintaining consistency across resources helps with identifying divergence from policies.
- **Automation:** Having an organizational scheme is beneficial for automations in creating resources, monitoring operations and creating DevOps processes.

See [this documentation](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming-and-tagging-decision-guide?toc=%2Fazure%2Fazure-resource-manager%2Fmanagement%2Ftoc.json) for more details on tags and their benefits.

Each resource group or subscription can have up to 5O tags in the form of key-value pairs. An important note is that the resources within a scope are not going to inherit tags from that scope. Also, note that you cannot define tags at the management group level, but you can at subscription level.

## Moving resources across resource groups or subscriptions
In certain scenarios we might want to move resources across resource groups or subscriptions. Pay attention to the following details: 
- When moving a resource to a target resource group, the original location of the resource is preserved, regardless of the location of the target resource group
- If you move a resource that has an Azure role assigned directly to the resource (or a child resource), the role assignment isn't moved and becomes orphaned. After the move, you must re-create the role assignment.
- The source and destination subscriptions must exist within the same Microsoft Entra tenant.
- If we're moving a resource across subscriptions, all its dependent resources will also have to move to the target subscription, i.e., Azure App Service Plan and an Azure App Service. Also, all the dependent resources should be part of the same resource group before the migratioin.

See [this documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/move-resource-group-and-subscription) for more details on limitations and things to consider before moving resources across resource groups or subscriptions.

## Resource Locking
As an administrator you can lock your resources to protect them against modifications or deletions. Resource locking will override any user permission.
- Use the **CanNotDelete** lock to authorize users to read and modify resources, but not delete them. 
- Use the **ReadOnly** lock to authorize users to only read the resources, but not modify nor delete them. 

Note that you can define resource locking for your subscription, resource groups and resource scopes to protect your resources against deletions and modifications. Resource locking are inherited by lower-level resources within a scope. Note that you cannot define locking at the management group level.

Unlike RBAC, locks are implemented across a scope for all users and groups.

## Resource locking and moving resources
A scenario that could take place is a case where we're applying a ReadOnly lock at the resource group level and try to move a underlying resource, i.e., a VM within that resource, to another resource group. 

The above operation cannot take place, since moving that underlying resource will modify the properties of the resource group, for which a ReadOnly lock has been enforced. 

The same logic applies for the target resource; if there's a ReadOnly lock on it, we cannot move any resource to it.

## Azure Policy Service
You can define Azure Policy to define compliance conditions, and the actions/effects to take when those compliances are not met. Below are the fields within policy definitions. See [the documentation](https://learn.microsoft.com/en-us/azure/governance/policy/concepts/definition-structure-basics#policy-type) for more details. 
- ```DisplayName```: Used to identify the policy
- ```Description```: Provides context into the policy
- ```Mode```: Determines the type of resources affected by the policy: ```ìndexed``` refers to resources that support tags and locations, and ```All``` would target all resources. An example scenario when ```indexed``` mode would be suitable is when enforcing tags and locations for the resources.
- ```Metadata```: 
- ```Parameters```:
- ```PolicyRule```:
 - ```Logical Operator```
 - ```Effect```

### Scopes for Azure Policy
Once business rules have been formed, you can define policies for any resource that Azure supports, i.e., management groups, subscriptions, resource groups or individual resource. Note that Azure policy exclusions cannot be set at the management group level.

### Azure Policy remediation task
While creating the policy, we can go ahead and enable remediation for the policy. This option will apply the new policy for existing resources that are not compliant. For this, it'll use a managed identity with a contributor role to access and modify the existing resources, i.e., add a tag to resources if the policy is about tags.

### Not Allowed Resource Type in Azure Policy
There's one policy called Not Allowed Resource Type, within which you can specify the resources that can not allowed to be deployed over a scope, i.e., resource group. Note that Azure Policy will not affect existing non-compliance resources by default, but will prevent creating of new non-compliant resources.

# Monitor and back up Azure resources
## Alerts in Azure Monitor
You can define alerts on both metrics and log data in Azure Monitor. An alert rule consists of the following:
- The resource to be monitored, i.e., an Azure Virtual Machine
- The second step is to define a condition, within which we specify the singnal or data from the resouce, i.e., CPU utilization within an Azure VM, to be monitored. Within the condition tab we need to specify the threshold under which an alert should be triggered. 
- The next step would be to define an action group, within which we define a notification type, i.e., email or sms, and an action type to be triggered, i.e., running an Azure Function or a Logic App pipeline.

There are 4 different severity levels for the alert rule: 
- 0-Critical
- 1-Error
- 2-Warning
- 3-Informational
- 4-Verbose

For more details on how to define rules for an alert, see [this documentation]((https://learn.microsoft.com/en-us/azure/azure-monitor/alerts/alerts-overview)).

### different alert types
- **Metric alerts:** Metric alerts evaluate resource metrics at regular intervals.
- **Log search alerts:** With log search alerts, you can use log analytics queries to evaluate resource logs at a predefined frequency.
- **Activity log alerts:** Activity log alerts are triggered when new log events are produced that match the predefined condition. Resource health alert and service health alerts are activity log alerts that monitor the health of your resource and services.
- **Smart detection alerts:** Smart detection alert on application insight resource warns you automatically on potential performence issues and anomolies in your web application.

### Alerts and state
- Stateless alerts: These alerts are triggered whenever the condition is matched, even if fired previously. All activity log alerts are stateless.
- Stateful alerts: There are triggered once the conditions are matched, but won't get triggered again unless the alert is resovled. Stateful alerts keep track of the alert status; once fired, they'll hold a "fired" status, and when resolved, the alerts send a resolved notification and update the status to resolved. 

## Log Analytics and Data Collection Rules
In order to direct VM logs into the Log Analytics Workspace, we define something known as Data Collection Rules in Azure Monitor, within which we define VM as the source and choose the type of data from the VM we'd like to capture, and then choose Log Analytics Workspace as the destination. 

When Data Collection Rule has been defined against a source Azure virtual machine, Azure Monitor will automatically install an agent on the source VM; 

Note that we can use as many VMs as required as the source resource within the same Data Collection Rule.

See [this documentation](https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/data-collection-rule-overview?tabs=portal) for more details on Data Collection Rules.

### Log Analytics Queries
Here's an overview of some of the most important queries using KQL within Log Analytics from the perspective of the AZ-104 exam. 

- This can be used for search for a keyword in the event table

```
Event | search "demovm"
```

2. This can used to pick up 5 events taken in no specific order

```
Event | top 10 by TimeGenerated
```

3. This is used to filter based on a particular property of an event

```
Event | where EventLevel == 4
```

4. This can be used to check for the events generated in the previous 5 minutes

```
Event | where TimeGenerated > ago(5m)
```

5. This can be used to project certain properties

```
Event | where TimeGenerated > ago(5m) | project EventLog, Computer
```

6. Here you can summarize the events

```
Event |  where TimeGenerated > ago(1d) | summarize count() by Computer,Source
```

7. Here you can render a bar chart based on the data

```
Event |  where TimeGenerated > ago(1d) | summarize count() by Computer,Source | render barchart
```

## Extending Azure Monitor: 
Azure Monitor starts to collect data as soon as the resources, like Azure VM, are created. However, we can extend data that is collected by Azure monitor by:
- **Enabling diagnostics:** For some resources like Azure SQL, you only have access to the full version of logs when diognostics is enabled. 
- **Using an agent:** For Virtual Machines, you can install a log analytics agent and configure it to send data to Log Analytics workspace. By doing this, you increase the extent of data collected in Azure Monitor. This agent is automatically installed on the VM as soon as a Data Collection Rule has been configured on the VM as the source.s

## Azure VM Insight
As discussed before, you can define Data Collection Rules on your VMs and send certain log data to the Log Analytics Workspace using an agent on the source VM, and then start running your queries and peform aggregations, analysis and visualizations on the results and define log search alerts. However, with the help of a feature called Azure VM Inisht in Azure Monitor, certain metrics get automatically detected and you get notified in cased of any any performance, network or health anomolies. 

In order to take advantage of this feature, it has to be enabled under the "insight" tab of the VM resource. Here's what it does: 
- Helps to monitor the heath and performance of Azure VMs.
- Helps to identify performance and network issues in your Azure VMs.
- Has support for VMs, VM scale-sets and on-premise machines.

## Configure file and folder backups
Azure backup replaces your off-site or on-premise backup solution with cloud-based solution that's secure, cost-effective and reliable.

Azure backup offers multiple components or agents that you download and deploy on the appropriate server, computer, or in the cloud. The component, or agent that you choose depends on what you'd like to protect; all Azure backup components can be used to backup data to a **Recovery Service Vault**. Here are the benefits of Azure Backup:
- Azure Backup provides an easy solution for backuing up your on-premises resources in the cloud. Get short- and long-term backups without having to deploy complex on-premise backup solutions.
- Azure Backups provide independent and isolated backups to protect againt accidental data loss; all backups are stored in Azure Recovery Services vault with built-in management of recovery points.
- You get unlimited data transfer for your inbound and outbound operations. Outbound refers to tranferring backup data from the vault during a restore operation. There's a cost associated with inport/export operations depending on the amount of data.
- Security: Data encryption during transmission and storage of your data in the cloud. The encyption passthrough is stored locally without any access in the cloud.
- Azure Backup provides application-consistent backups, which ensure extra fixes aren't required to restore the data. This leads to reduction in restoration time and that you can quickly return to the previous running state.
- There's no limit in how long you'd like to keep the backups in the Services Recovery Vault. Azure backup has a limit of 9,999 recovery points per protected instance. 
- It provides LRS (copies data 3 times in a single physical location within the primary regions) and GRS (copies the data to a seconday region) storage options for your backup data.

**NOTE -** If you're using Azure Backup for Azure Files file shares, you don't need to configure the storage replication type. Azure Files backup is snapshot-based, and no data is transferred to the vault. Snapshots are stored in the same Azure storage account as your backed-up file share.

### Azure VM backup
In order for the backups to be implemented, an extention needs to be installed on the agent running in the Azure VM. The first step in implementing a backup for Azure VM is to deploy a Azure Recovery Services Vault. It's a management entity that stores recovery points over time, and it provides an interface for peforming backup-related operations.

#### Azure Backup Policy
When the recovery services vault is created, you can set up a backup policy in which you can determine the backup schedule. The default policy creates a backup once a day and retains them for 30 days; we can create a new policy to define those settings for your use case. Here are a few notes on Backup policy:
- The services recovery vault should be in the same region as the Virtual Machine
- Once we enable the backup, it'll deploy the new policy to the recovery services vault and installs the backup extension on the VM agent installed in Azure VM.
- The backup tool first takes a snapshot of the data in the VM
- The snapshot is then copied into the Recovery Services Vault.

The following settings needs to be specified when creating a backup policy:
- policy name; Name for the new policy 
- schedule: How often the backups should take place.
- instant restore: Specify how long you'd like to retain snapshots locally
- retention range: Specify how long you'd like to keep your daily, weekly, monthly or yearly backups.

#### File Recovery
Once the backup has ended and the snapshot has been created locally in the VM and copied in the recovery services vault as well, we can go ahead and perform a File Recovery under the "backup" tab of the VM resource. This feature allows us to recover specific files from the data in the VM. While performing the file recovery, we need to choose the following: 
- Recovery Point: Corresponds to a specific snapshot taken of the VM data
- Download an executable: This will mount the disk from the recovery point to the local machine on which it runs.

#### VM Recovery
This feature allows us to restore the whole VM. We can choose to create or replace the existing VM or Data Disk for the VM recovery feature. For this, we'll need a Storage Account in place; this is used as staging environment to copy the data from restore point in a recovery services vault.

#### Azure Recovery Services (MARS) Agent
In the previous section we looked at how we get a snapshop of the whole VM using the recovery services vault. However, there are certain scenarios where we'd like to back up a selective number of files or folders. For this, we can use the Recovery Services Vault Agent (MARS):
- Using this agent, you can perform select backup of file and folders, or even the whole Windows volume
- This can be used on your Azure VMs or on-premise machines
- The recovery services agent needs to be downloaded and installed

#### Azure Backup Reports
We can enable diagnostic logs for the recovery services vault resource and send its backup data to either a Storage Account or a Log Analytics Workspace to have backup reports. As a destination for the diagnostic logs, we can either choose a storage account or a log analytics workspace.

Note that for storage account, it has to be in the same region as the recovery services vault. However, for log analytics workspace, there's no limit for the region.

## Azure Site Recovery
It's a feature for Azure VMs that helps to support business continuity and disaster recovery. It ensures that your apps and workloads are running when there are planned or unplanned outages. This feature is available not only for Azure VMs, but also on on-premise centers and data centers.

using this feature, the data, apps, and workloads running on a primary server get continuously replicated to a secondary server to ensure continuity of critical applications; and if there are changes implemented on the application running on the primary servers, those changes have to be instantly replicated on the secondary server as well.

This feature is preferred over the backup solution for business critical applications where instant failover to the secodary region is absolutely necessary and waiting for a backup tool is not an option. Since backup occurs on a schedule, i.e., every few hours, and it takes certain amount of time for the backup to succeed (local snapshot and copy into the recovery services vault), we might need to use such replication technologies for cases where continuous replications are required.

### Configure Network watcher
Network watcher enables you to monitor and repair the network health of IaaS services, such as Virtual Machines, VPN Gateways, Load Balancers etc. It provides 3 important capabilities: Monitoring, Network diagnostic tools, and Traffic. See all the [documentation](https://learn.microsoft.com/en-us/azure/network-watcher/network-watcher-overview#monitoring). 

**Monitoring**
- Topology - Provides a visualization of the entire network for understanding network configurations. Provides an interactive space for understanding the resources and their relationships. 
- Connectioin Monitor - It helps you understand the network performance between different endpoints in your network infrastructure. It monitors the connections on a continuous basis, as opposed to connection troubleshoot, which monitors at a point in time. 

**Network diagnostic tools**
- Next hop - This helps you to detect routing issues and to understand whether a packet of data is reaching its destination. It provides information about the next hop type, IP address, and the route table ID for a destination IP address. This feature is quite useful when we have a user-defined route in our architecture. If there's an intermediate step before the traffic reaches its destination i.e., a virtual network appliance, then the next hop feature within the Network Watcher is useful to verify the next hop.
- Ip flow verify - This shows traffic filtering issues at the virtual machine level. This allows to see if a packet is allowed or denied to or from a virtual machine. If a packet is being denied due to a security group, it shows which rule is denying that packet. This feature is ideal to ensure correct implementation of your security rules.
- Connection troubleshoot - Connection troubleshoot enables you to test a connection between a virtual machine, a virtual machine scale set, an application gateway, or a Bastion host and a virtual machine, an FQDN, a URI, or an IPv4 address. The test returns similar information returned when using the connection monitor capability, but tests the connection at a point in time instead of monitoring it over time.
- Effective security rules - It allows you to view the effective security rules applied to a network interface. It shows you all security rules applied to the network interface, the subnet the network interface is in, and the aggregate of both.
- Packet capture - It allows you to create packet capture sessions to track traffic to and from a virtual machine or virtual machine scale set. 
- VPN troubleshoot - Allows you to troubleshoot virtual network gateways and their connections.
- NSG diagnostics - Similar to If Flow Verify, but with more functionalities. It provides information about whether a packet of data is allowed to denied to or from an IP address, IP prefix, or service tag.

**Traffic** Network Watcher offers two traffic tools that help you log and visualize network traffic: Flow logs, and Traffic analytics.
- NSG Flow logs - Helps you to log information about your Azure IP traffic and stores the data in Azure storage. You can log IP traffic flowing through a network security group or Azure virtual network. So, if you want to get the entire log information about traffic flow through a network security group, we an take advantage of IP Flow Log.
- Traffic Analytics - Provides rich visualizations of flow logs data

### Azure Firewall
The purpose of Azure firewall is to ensure outbound and inbound communications to the internet are safe. For this, we need to make sure it has a public ip address to have an interface to the internet.