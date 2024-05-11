# Implementing security on Azure Storage Accounts with Terraform
## Introduction
This documentation outlines the implementation of security measures in Azure Storage Accounts leveraging service endpoints and private endpoints. The project aims to demonstrate the setup and configuration of these features using Terraform, following a modular approach.

## Goals and Objectives
The primary goals of this project are:
- Learn about and implement security measures in Azure Storage Accounts.
- Understand the concept and implementation of service endpoints and private endpoints.
- Deploy the infrastructure using Terraform modules to ensure scalability and maintainability.

## Created Azure Resources
- **Resource Group**: Represents the logical container for grouping Azure resources.
- **Virtual Network**: Provides the foundational networking infrastructure for Azure resources.
- **Subnet**: Defines a segmented portion of the virtual network where Azure resources (in this case a VM) can be deployed.
- **Network Security Group**: Acts as a virtual firewall to control inbound and outbound traffic to Azure resources.
- **Network Interface**: Represents the network interface attached to a virtual machine.
- **Public IP Address**: Provides a public IPv4 address that is attached to the network interface of the VM
- **Windows Virtual Machine**: Represents a virtual machine running the Windows operating system. This resource has been created to test connections to the two storage accounts with service and private endpoints enabled. We've installed Azure Storage Explorer on the VM and established a successful connection to the storage accouts once the endpoints have been created
- **Storage Accounts**: Two storage accounts have been created, ```saprivateendpointdev``` with a privated endpoint enabled, and ```saserviceendpointdev``` with service endpoint enabled.
- **Private DNS Zone**: Provides a private DNS namespace for resolving Azure resources within the virtual network. The name to this private DNS zone has to be ```privatelink.blob.core.windows.net``` in order to establish a fully qualified domain name (FQDN) for the endpoint.
- **Private DNS A Record** Maps a hostname to the IP address of the private endpoint within the private DNS zone. This step is very important in implementing a private endpoint for the storage account.
- **Private DNS Virtual Network Link** Establishes a link between the private DNS zone and the virtual network. This step is required in order to be able to add that A record in the previous step.
- **Private Endpoint** Represents a private endpoint for accessing Azure Storage Accounts privately from within the virtual network.

These resources collectively form the infrastructure required to implement security measures in Azure Storage Accounts using service and private endpoints, all deployed using Terraform with a modular approach. Each resource plays a specific role in ensuring the security, connectivity, and functionality of the Azure environment.

## Using Terraform for Azure Infrastructure Deployment
Utilizing Terraform for deploying infrastructure into Azure, particularly employing modular approaches, offers several advantages:
- **Infrastructure as Code (IaC):** Terraform enables the definition of infrastructure configurations as code, allowing for version control, code review, and repeatability. This approach enhances consistency and reliability across deployments.
- **Declarative Configuration:** With Terraform, infrastructure is defined declaratively, specifying the desired end-state rather than the procedural steps to achieve it. This simplifies configuration management and reduces the risk of configuration drift.
- **Scalability and Maintainability:** Modularization in Terraform promotes reusable and scalable infrastructure components. Using modules abstracts complexities and fosters maintainability by encapsulating configurations into manageable units.
- **Automation and Consistency:** Terraform automates the deployment and management of Azure resources, reducing manual intervention and ensuring consistency across environments. This automation streamlines operations and minimizes the likelihood of human errors.
- **Provider Agnosticism:** Terraform supports multiple cloud providers, including Azure, AWS, Google Cloud Platform, etc. This provider agnosticism allows organizations to adopt a multi-cloud strategy or migrate between cloud platforms with ease.
- **Community and Ecosystem:** Terraform benefits from a vibrant community and ecosystem, offering a vast library of community-maintained modules, plugins, and integrations. Leveraging these resources accelerates development and enhances productivity.

In summary, leveraging Terraform for deploying infrastructure into Azure, especially utilizing modular approaches, provides numerous benefits, including enhanced automation, scalability, maintainability, and consistency. By embracing Infrastructure as Code principles, organizations can streamline their Azure deployments, improve operational efficiency, and achieve greater agility in managing cloud infrastructure.

# References
[Creating a private endpoint for Azure storage account using Terraform](https://dev.to/agsouthernt/creating-a-private-endpoint-for-azure-storage-account-using-terraform-1f3g)

[Quickstart: Create a private endpoint by using Terraform](https://learn.microsoft.com/en-us/azure/private-link/create-private-endpoint-terraform?tabs=azure-cli)