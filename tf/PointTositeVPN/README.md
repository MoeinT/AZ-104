# Azure Point-to-Site VPN
Azure Point-to-Site (P2S) VPN is a type of VPN connection that allows individual devices to connect securely to an Azure Virtual Network. In a Point-to-Site VPN, the connection is initiated from the client device rather than the virtual network, making it suitable for connecting individual users working remotely or on-the-go. P2S VPN is also a useful solution to use instead of S2S VPN when you have only a few clients that need to connect to a VNet.

## Key features of Azure Point-to-Site VPN
**Secure Connection:** Point-to-Site VPN uses the Secure Socket Tunneling Protocol (SSTP) or OpenVPN protocols to ensure a secure and encrypted connection between the client and the Azure Virtual Network.

**Authentication:** It supports various authentication methods, such as Azure Active Directory (Azure AD), certificates, or a combination of both, providing flexibility in managing access to the virtual network.

**Client Platform Support:** Azure Point-to-Site VPN is compatible with various client platforms, including Windows, macOS, Linux, iOS, and Android.
## Architecture diagram