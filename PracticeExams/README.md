Question 1: 
- **You've been asked to identify latency issues between two virtual machines in Azure. Which Azure service would provide you with the ability to check for network communication between the two VMs?**

To identify latency issues between two virtual machines in Azure, you can use Azure Network Watcher. Azure Network Watcher is a network performance monitoring and diagnostic service that allows you to gain insights into the health and performance of your Azure network.

- **Your organization has decided to employ Azure Bastion for securely accessing VMs and to set up Azure PaaS services with enhanced network security. What is the immediate benefit of using Azure Bastion in this context?**

Azure Bastion provides a seamless RDP and SSH connectivity to VMs, without exposing IPs to the internet. It'd be possible to log into the VMs directly using the Azure Console. 

- **You are deploying a web application in Azure and want to ensure its high availability and that it uses a custom domain. Which of the following steps should you take?**

Register a custom domain using Azure DNS service: DNS is a fundamental component of the internet and translates human-readable domain names into IP addresses. In case of a load balancer, when a user enters a domain name (e.g., www.yourdomain.com) into their browser, the DNS system resolves this domain to the IP address of the load balancer.

Use a DNS (domain name service) in conjuction with a load balancer to ensure high availability: While DNS itself doesn't perform the traffic distribution or failover directly, it plays a crucial role in enabling users to access a service using a human-readable domain name. The combination of *DNS resolution* and load balancing helps ensure high availability, fault tolerance, and efficient traffic distribution in web applications.

- **You've been asked to identify latency issues between two virtual machines in Azure. Which Azure service would provide you with the ability to check for network communication between the two VMs?**

Connection monitor is a service within Azure Network Watcher that monitors network connections. A common scenario is to monitor and assess network connections between two servers in a multi-tier application. It also allows you to assess cross-region network latencies; i.e., a VM/Scalesets can ping a VM/Scaleset in another region to assess network latencies. See the [documentation](https://learn.microsoft.com/en-us/azure/network-watcher/connection-monitor-overview) for more details on Connection Monitor and Azure Network Watcher. 

- **To analyze system updates across multiple virtual machines, which feature of Azure Monitor should you utilize?**
This would be Log Analytics. Using this feature we can query and analyze logs from difference sources. See the [doc](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/log-analytics-tutorial) for more details.

- **You are tasked with setting up notifications for your team whenever CPU usage exceeds 90% on any virtual machine for a duration of 10 minutes. Which of the following components in Azure Monitor would be crucial to achieve this?**

*Azure Monitor Metrics:* Azure Monitor Metrics provides a variety of metrics, including CPU usage, for monitored resources such as virtual machines. You can use the CPU usage metric to define conditions for triggering alerts.
*Azure Monitor Alerts:* Azure Monitor Alerts allows you to set up alert rules based on conditions defined by metric values.
You can create an alert rule that specifies conditions like CPU usage exceeding 90% for a duration of 10 minutes.
*Action Groups:* Action Groups in Azure Monitor allow you to define a list of actions to be taken when an alert is triggered.

- **You're planning to safeguard your data against data loss in Azure. Which of the following would you utilize to store backup data, such as files, folders, and system state?**

You can use Recovery Services vaults to hold backup data for various Azure services such as IaaS VMs (Linux or Windows) and SQL Server in Azure VMs. Recovery Services vaults support System Center DPM, Windows Server, Azure Backup Server, and more. Recovery Services vaults make it easy to organize your backup data, while minimizing management overhead.

- **What is the primary purpose of Azure Policy?**
Its primary purpose is to allow you to define and apply policies that govern the configurations of your Azure resources. These policies can enforce rules and effects on resources, helping maintain consistency, security, and compliance within your Azure environment.

- **In Azure, Role-Based Access Control (RBAC) can be assigned at various levels. Which of the following scopes are valid levels for assigning roles in Azure?**
Scope is a set of resources that an access can be applied to. In Azure, you can specify a scope at four levels: management group, subscription, resource group, or resource. Scopes are structured in a parent-child relationship. Each level of hierarchy makes the scope more specific. *What are management groups:* If your organization has many Azure subscriptions, you may need a way to efficiently manage access, policies, and compliance for those subscriptions. Management groups provide a governance scope above subscriptions. See the [doc](https://learn.microsoft.com/en-us/azure/governance/management-groups/overview). 

- **How are Tags useful in Azure Resources -**
Organizing Resources: Tags help you organize and categorize your resources based on various criteria such as environment (e.g., production, development, testing), department, project, or cost center.
Cost Management: Tags are instrumental in cost management by allowing you to track and allocate costs to specific categories.
Automation and Policies: Tags can be used in Azure Policy definitions to enforce specific rules and compliance standards across resources. Policies can be configured to evaluate and enforce tagging conventions, ensuring that all resources adhere to specified tag requirements.

- **What does Azure Advisor provide recommendations for?**
Azure Advisor analyzes your configurations and usage telemetry and offers personalized, actionable recommendations to help you optimize your Azure resources for reliability, security, operational excellence, performance, and cost.

- **When creating and managing Azure file shares, which of the following features are available?**

*Soft delete* for Azure file shares allows you to recover your data when file shares or the share snapshots are accidentally deleted.
Snapshots for Azure file shares provide a way to back up and restore your data, serving as read-only versions of the share.

- **Azure Blob Lifecycle Management allows you to create rule-based policies that automate the transition of blobs to cooler storage tiers (hot to cool, or cool to archive) or even delete them at the end of their lifecycles. It helps in optimizing costs and ensuring data is stored efficiently as it ages.**

- **Your organization follows strict security policies, and you are required to generate a SAS token for a container in a storage account. You also need to ensure that if the security requirements change, the SAS token permissions can be altered without regenerating the token. What should you use?**

**User delegation SAS -** A user delegation SAS is secured with Microsoft Entra credentials and also by the permissions specified for the SAS. A user delegation SAS applies to Blob storage only.

**Service SAS -** A service SAS is secured with the storage account key. A service SAS delegates access to a resource in only one of the Azure Storage services: Blob storage, Queue storage, Table storage, or Azure Files.

**Account SAS -** - An account SAS is secured with the storage account key. An account SAS delegates access to resources in one or more of the storage services. All of the operations available via a service or user delegation SAS are also available via an account SAS.

A shared access signature can take one of the following two forms:

**Ad hoc SAS -** When you create an ad hoc SAS, the start time, expiry time, and permissions are specified in the SAS URI. Any type of SAS can be an ad hoc SAS.

**Service SAS with stored access policy -** A stored access policy is defined on a resource container, which can be a blob container, table, queue, or file share. The stored access policy can be used to manage constraints for one or more service shared access signatures. When you associate a service SAS with a stored access policy, the SAS inherits the constraints—the start time, expiry time, and permissions—defined for the stored access policy.

**Explain different redundancy solutions in Azure -**

**Primary Region**
Locally redundant storage (LRS): It copies your data 3 times within a single physical location in the primary region.
Zone redundant storage (ZRS): It copies the storage account synchrounsly in 3 different Azure Availability Zones within the primary region.
**Seconday Region**
Geo redundant storage (GRD): It copies the data 3 times in a physical location in the primary region using LRS. It then copies the data to a physical location in the secondary region. 
geo zone redundant zone - It copes the data across Azure Availability zones using ZRS, but it then creates a copy of the data in a physical location in a secondary regioin. 