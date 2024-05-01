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

## Configure Azure Load Balancer
See the learning path to review this section.

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

Also, there are two tiest for ALB; read in more details in [this](https://learn.microsoft.com/en-us/training/modules/improve-app-scalability-resiliency-with-load-balancer/2-load-balancer-features) documentation.

### Internal load balancer
In addition to forwarding traffic from users to the front-end servers, you can use Azure Load Balancer to forward traffic from front-end servers evenly to the backend servers. In some applications, the frontend calls for business logic in servers hosted in the middle tier. You'd want to make sure the middle tier is also as scalable and resilient as the middle tier; in order to do so, we can use an internal load balancer. See [this](https://learn.microsoft.com/en-us/training/modules/improve-app-scalability-resiliency-with-load-balancer/5-internal-load-balancer) page to read more on an interesting scenario where internal load balancers are very useful.

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
### Web App Loggin
There are different logging capabilities in Azure Web App:
- **Application loggings:** This captures log messages that are generated by the application code. This can be at the filesystem level or blob storage level.
- **Server logging:** This records raw HTTP mrssages
- **Detailed error messages:** Copies the .html error pages that would've been sent to the client browser. 
- **Deployment logging:** Information recorded when changes are published to the web application. 
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
Backup for the application
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

## Point to site VPN connection
Point to site VPN connections allow you to establish a connection between Azure Virtual Network and client machines. Imagine a scenario where we'd like to establish a connection between a client machine and a web application running on a Virtual Machine in an Azure Virtual Network. Normally, such connection is not possible, since no public IP is assined to this Virtual Machine. In such cases, we can use something known as Point to site VPN connection. Here are the required steps to implement this solution on a high level: 
- Create an Virtual Private Network Gateway resource and attach it to the virtual network hosting the VM
- Create an empty Gateway subnet to host the VMs that are responsible for the routing of traffic between client machines and the VMs in the Virtual Network.
- In order to connect the client machines from the internet onto the VNet through the VPN Gateway, there should be a sort of authentication mechanism in place. One way for clients machines to authenticate into the Vnet is through certifications. So, there should be a certificate in place in the client machine for the Vnet to recognize. See the Microsoft [documentation](https://learn.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-certificates-point-to-site) on how we can generate a certification for authentication.

Once a VPN connection has been properly established, we would be able to log into the application running on a VM in the Vnet directly from our machine.

## Site to site VPN connection
There are certain scenarios where we would like to connect an entire on-premises network, i.e., client machines, servers, to the workloads in the Vnet. For such scenarios, we can make use of site-to-site VPN connection. Here are the requirements for establising a site-to-site VPN connection.

- On the on-premise side, you need to have a VPN device that can route traffic via the Internet onto the VPN gateway in Azure. The VPN device can be a hardware device like a Cisco router or a software device ( e.g Windows Server 2016 running Routing and Remote services). The VPN device needs to have a publically routable IP address.

- The subnets in your on-premise network must not overlap with the subnets in your Azure virtual network.

- The Site-to-Site VPN connection uses an IPSec tunnel to encrypt the traffic.

- The VPN gateway resource you create in Azure is used to route encrypted traffic between your on-premise data center and your Azure virtual network.

- There are different SKU's for the Azure VPN gateway service. Each SKU has a different pricing and attributes associated with it. See the [doc](https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-about-vpn-gateway-settings). 

**NOTE -** Site-to-site VPNs use IPSEC to provide a secure connection between your corporate VPN gateway and Azure.

## Azure Virtual WAN
There are certain scenarios where we would like to connect a range on on-premise infrastructure, i.e., office branches, to multiple Vnets in Azure. One way to tackle this is to use a VPN Gateway to establish a connection between an on-premise resource to a Vnet, and establish a Vnet peeting to the second Vnet. This is due to the fact that VPN Gateways can only establish a connection to maximum one Azure Vnet. 

For such scenarios where there are a high number of Azure Vnets and a high number of office locations, we can make use of Azure Virtual WAN. In kind of a mesh network, you can connect your multiple virtual networks onto the WAN. Here's how to simulate a scenario for Azure Virtual WAN:
- Create two Vnets each hosting a VM that have IIS installed on them. These Vnets have no peerings between them.
- Deploy an Azure Virtual WAN resource.
- Deploy a virtual Hub, which is a Vnet used for the Azure Virtual WAN.
- Next step would be to connect our Vnets to the virtual hub.

# Implement and manage storage in Azure
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
### Secure storage endpoints
You can use Azure service endpoints to restrict access to a storage account to only resources within a Vnet or Subset. An Azure Service Endpoint will extend a Vnet's IP address range by incorporating that storage account into its space. This way, access to the storage account will be possible through IP Address exception and firewall openings.

Another approach to securing the storage account would be to create a private link to resources within a Vnet. So, the advantage to this approach is that communications between resources in a Vnet/Subnet to this storage account is established through the Microsoft backbone network infrastructure and will be go through the public internet. See [this] (https://www.youtube.com/watch?v=vM7yDwHSc_o) video for more details on how to create a private link to an Azure Storage Account.

## Configure Azure Blob Storage
It's a service for storing large amounts of unstructured data; data that does not adhere to any model or definition.
### Blob Access Tiers
There are 3 access tiers for blob data, Hot, Cool & Archive. Each one is optimized for a specific pattern of data usage.
- **Hot -** The Hot tier is designed for the frequent read and write of objects in the storage account. By default, SAs are created in the HOT tier; it has the lowest access costs and highest storage cost.
- **Cool -** This tier is designed for storing large amounts of objects that are infrequently accessed. Data must remain untouched for at least 30 days for this tier. A example use case would be short-term backup files and disaster recovery datasets. It's a cost-effective option for data storage and more expensive than the hot tier for accessing data. 
- **Archive -** It's an offline tier for storing data and is optimized for use cases that can tolerate hours of latency. Data must remain in the storage account for at least 180 days otherwise will be subject to early deletion charges. It's the most cost-effective option for storing data and the most expensive for accessing it. Data for the Archive tier includes secondary backups, original raw data, and legally required compliance information.
### Lifecycle management rules
Azure blob storage supports lifecycle management rules; we can use it to transition to the right access tier. 
# Manage identities and governance in Azure
## Configure Microsoft Entra ID
Microsoft Entra ID is a cloud-based identity and access management service. See [this](https://learn.microsoft.com/en-us/training/modules/configure-azure-active-directory/2-describe-benefits-features) documentation for details on its capabilities.

### Resource Locking
As an administrator you can lock your resources to protect them against modifications or deletions. Resource locking will override any user permission.
- Use the **CanNotDelete** lock to authorize users to read and modify resources, but not delete them. 
- Use the **ReadOnly** lock to authorize users to only read the resources, but not modify nor delete them. 

Unlike RBAC, locks are implemented across a scope for all users and groups. 

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

### Difference between RBAC and Microsoft Entra Id
**Access management -** RBAC controls access to Azure resource, so it provides a more granular access management for Azure resources, but Microsoft Entra provides access to Microsoft Entra resources.
**Scope assignment -** RBAC can assign roles at difference scope, but Microsoft Entra Id provides access at the tenant level.
**Roles -** RBAC has built-in roles and has the possiblity to create custom roles as well, but with Entra Id offers administrator roles to manage Entra Id resoureces. Here's Microsoft Entra Id administrator roles: *Global admin*, *Application admin*, and *Application developer*.

## Create Azure users and groups in Microsoft Entra ID
Imagine a scenario where you're a Microsoft Entra Id global administrator. A new team of developers are to be onboarded to develop and host an application in Azure. There are a number of external users who are to be consulted for the application design. Here's the goal:
- The goal is to create external users in Microsoft Entra Id for external users.
- We should also create groups to manage access to the application resource

There are 3 ways we can assign roles to users:
- Direct assignment
- Group assignment
- Rule-based assignment

## Configure Azure Policy
You can define Azure Policy to define compliance conditions, and the actions/effects to take when those compliances are not met. Below are the fields within policy definitions. See [the documentation](https://learn.microsoft.com/en-us/azure/governance/policy/concepts/definition-structure-basics#policy-type) for more details. 
- ```DisplayName```: Used to identify the policy
- ```Description```: Provides context into the policy
- ```Mode```: Determines the type of resources affected by the policy: ```ìndexed``` refers to resources that support tags and locations, and ```All``` would target all resources. An example scenario when ```indexed``` mode would be suitable is when enforcing tags and locations for the resources.
- ```Metadata```: 
- ```Parameters```:
- ```PolicyRule```:
 - ```Logical Operator```
 - ```Effect```

# Monitor and back up Azure resources
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

### Microsoft Azure Recover Services Agent
Azure uses a MARS agent for backing up files, folders, system data from your on-premise machines and azure VMs. This agent is to be installed on your windows machine.

### Configure Azure Monitor
Azure monitor is a comprehensive service that collects, analyzes and responds to relemetery data from both on-premise and cloud environments. An example scenario is to use this service to monitor the performance of your online applications and identify potential issues to maximize your application's availability and performance and improve customer experience. Here are 3 important capabilities of Azure monitor: 
- **Collection:** It collects numerical data from your Azure resources
- **Troubleshoot and visualize:** Azure Monitor Logs (log analytics) provides activity logs, diagnostic logs and telemetry logs and provides query capabilities to troubleshoot and visualize your log data.
- **Alerts and actions:** Azure monitor allows you to set up alerts for gathered data to notify you when critical conditions arise. We can then design corrective actions in an automated way.

#### [Alerts in Azure Monitor](https://learn.microsoft.com/en-us/azure/azure-monitor/alerts/alerts-overview)
You can define alerts on both metrics and log data in Azure Monitor. An alert rule consists of the following:
- The resource to be monitored, i.e., an Azure Virtual Machine
- The singnal or data from the resouce, i.e., CPU utilization within an Azure VM
- And the condition under which an alert should be fired, i.e., if cpu utilization is above 80 %
- If we have more than one resource to be monitored, the alert rule condition is evaluated for each resource separately

##### Action Groups
- Once an alert is triggered, it will trigger an action group and updates the alert state for that resource. The alert instances of all your resource are stored for 30 days, and deleted after this 30-day retention period.

##### different alert types
- Metric alerts: Metric alerts evaluate resource metrics at regular intervals.
- Log search alerts: With log search alerts, you can use log analytics queries to evaluate resource logs at a predefined frequency.
- Activity log alerts: Activity log alerts are triggered when new log events are produced that match the predefined condition. Resource health alert and service health alerts are activity log alerts that monitor the health of your resource and services.
- Smart detection alerts: Smart detection alert on application insight resource warns you automatically on potential performence issues and anomolies in your web application.

##### Alerts and state
- Stateless alerts: These alerts are triggered whenever the condition is matched, even if fired previously. All activity log alerts are stateless.
- Stateful alerts: There are triggered once the conditions are matched, but won't get triggered again unless the alert is resovled. Stateful alerts keep track of the alert status; once fired, they'll hold a "fired" status, and when resolved, the alerts send a resolved notification and update the status to resolved. 

### Extending Azure Monitor: 
Because Azure Monitor is automatic, it begins to collect data as soon as the resources, like Azure VM, are created. We can extend data that is collected by Azure monitor by:
- Enabling diagnostics: For some resources like Azure SQL, you only have access to the full version of logs when diognostics is enabled. 
- Using an agent: For Virtual Machines, you can install a log analytics agent and configure it to send data to Log Analytics workspace. By doing this, you increase the extent of data collected in Azure Monitor.

### Configure Log Analytics
Azure Monitor collects log data and stores it in tables. We can use log analytics in the portal and specify the inpit data sources and queries for data that is collected in Azure Monitor logs. Queries provide insight into the system infrastructure, such as assessing system updates or operational insidents. We can use the Kusto Query Language (KQL) for analyzing and aggregating log data. Here's an example of cases where log analytics within Azure Monitor can be helpful:
- Abnormal behavior from a specific account
- Users installing unapproved software
- Unexpected system reboots or shutdowns
- Evidence of security breaches
- Specific problems in loosely coupled applications

### Configure Alerting
Here are 3 alert types: 
- **Metrics alerts:** Provide an alert trigger when a specified threshold is exceeded. For example, a metric alert can notify you when CPU usage is greater than 95 percent. 
-**Activity log alert:** Notifies you when a resource changes state, i.e., when a resource has been deleted.
- **Log alerts:** This is based on things written to log files. For example, a log alert can notify you when a web server has returned a number of 404 or 500 responses.

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
- Flow logs - Helps you to log information about your Azure IP traffic and stores the data in Azure storage. You can log IP traffic flowing through a network security group or Azure virtual network. So, if you want to get the entire log information about traffic flow through a network security group, we an take advantage of IP Flow Log.
- Traffic Analytics - Provides rich visualizations of flow logs data

### Azure Firewall
The purpose of Azure firewall is to ensure outbound and inbound communications to the internet are safe. For this, we need to make sure it has a public ip address to have an interface to the internet.

# Questions
**What's a stored access policy?** Provides an additional level of security over service-level shared access signature (SAS) tokens. You'd be able to change start time, expiry time or permission for a signature; useful for scenarios where the security requirements could change without having to recreate the token. See the [doc](https://learn.microsoft.com/en-us/rest/api/storageservices/define-stored-access-policy).

**What is object replication in Azure Storage:** Object replication asynchronously copies block blobs between a source storage account and a target one. For object replication, **change feed** and **blob versioning** must be enabled. Object replication only copies objects after replication, it does not copy pre-existing objects. 

**What is Azure file snapshot?** Azure Files provides the capability to take snapshots of file shares. Share snapshots capture the share state at that point in time. See this [doc](https://learn.microsoft.com/en-us/azure/storage/files/storage-snapshots-files) for example scenarios.

**What can you do with Bicep?** 
- Azure CLI can be used to directly convert ARM template JSON files to Bicep files.
- Bicep files can be deployed to Azure without first converting them to ARM templates, as Azure CLI and PowerShell can handle the transpilation for you.
- A Bicep file can also be translated to its equivalent ARM template, allowing users to see what the ARM JSON representation would look like.
- Validate a Bicep file using Azure PowerShell without deploying it. Use the what-if operation to verify that the Bicep file makes the changes that you expect.

**How can you ensure the confidentiality and security of data at rest within your Azure virtual machines**
- Azure Disk Encryption helps protect and safeguard your data to meet your organizational security and compliance commitments. It uses the BitLocker feature of Windows and the DM-Crypt feature of Linux to provide volume encryption for the OS and data disks of Azure VMs.
- Managed disks offer better reliability for Availability Sets by ensuring that the disks of VMs in an Availability Set are sufficiently isolated from each other to avoid a single point of failure.

**Containerized Application Workflow**
- Azure Container Registry is a managed, private Docker registry service based on the open-source Docker Registry 2.0. It enables you to store and manage container images across all types of Azure deployments.

- Azure Container Apps allows you to build, deploy, and scale containerized applications quickly, and it supports customization of scaling rules.

**How can we optimize a mission-critical Azure App Service for security, continuity, and agility?**
- Mapping a custom domain and configuring a managed certificate enhances the trustworthiness and security of the site.
- Regular backups ensure data integrity and availability.
- Deployment slots allow for testing in a near-production environment, improving deployment agility.
- Azure Private Link enhances security by allowing private connectivity from a virtual network to Azure platform as a service (PaaS) services.

**A few actions you can do with log alerts:**
- You can define metric alerts using log queries.
- Log alerts execute log queries at regular intervals, creating an alert if the results match certain conditions.
- Log alerts work for multiple resources, not just virtual machines.
- Action groups specify the actions to be taken when an alert rule fires.

**Can a VM with a basic Public IP address connect to a standard load balancer?**
- No, if we have a standard load balancer, and the backend VMs have a public IP address, it also has to be a standard IP address.

**Azure Web App and Azure Application Gateway**
- Imagine a scenario where requests to ```https://cloudportalhub.com``` should be routed to one Azure Web App, and the requests for ```https://cloudhublearning.com``` should be routed to another one; in this scenario, we'd use the [Multiple-site hosting](https://docs.microsoft.com/en-us/azure/application-gateway/features#multiple-site-hosting) feature of Azure Application Gateway.
- There's also the url-based routing in Application Gateway, which is for scenarios where you'd like to route incoming requests based on the url paths; for example, requests to ```http://contoso.com/video/*``` can be routed to one Azure Web App, and the requests for ```http://contoso.com/images/*``` can be routed to another one. Note the difference between the multi-site hosting and url-path based features.