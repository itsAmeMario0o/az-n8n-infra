# =============================================================================
# NETWORKING MODULE - OUTPUTS
# =============================================================================
# This file defines output values from the networking module that can be
# consumed by other modules or the root configuration. Outputs provide
# essential information about created networking resources.

# -----------------------------------------------------------------------------
# Virtual Network Outputs
# -----------------------------------------------------------------------------

output "virtual_network_name" {
  description = "Name of the created virtual network"
  value       = azurerm_virtual_network.main.name
}

output "virtual_network_id" {
  description = "Resource ID of the created virtual network"
  value       = azurerm_virtual_network.main.id
}

output "virtual_network_address_space" {
  description = "Address space of the virtual network"
  value       = azurerm_virtual_network.main.address_space
}

# -----------------------------------------------------------------------------
# Subnet Outputs
# -----------------------------------------------------------------------------

output "subnet_name" {
  description = "Name of the created subnet"
  value       = azurerm_subnet.main.name
}

output "subnet_id" {
  description = "Resource ID of the created subnet"
  value       = azurerm_subnet.main.id
}

output "subnet_address_prefixes" {
  description = "Address prefixes of the subnet"
  value       = azurerm_subnet.main.address_prefixes
}

# -----------------------------------------------------------------------------
# Network Interface Outputs
# -----------------------------------------------------------------------------

output "network_interface_name" {
  description = "Name of the created network interface"
  value       = azurerm_network_interface.main.name
}

output "network_interface_id" {
  description = "Resource ID of the created network interface"
  value       = azurerm_network_interface.main.id
}

output "private_ip_address" {
  description = "Private IP address assigned to the network interface"
  value       = azurerm_network_interface.main.private_ip_address
}

output "mac_address" {
  description = "MAC address of the network interface"
  value       = azurerm_network_interface.main.mac_address
}

# -----------------------------------------------------------------------------
# Network Configuration Outputs
# -----------------------------------------------------------------------------

output "network_config" {
  description = "Complete network configuration used for this deployment"
  value = {
    vnet_cidr           = var.network_config.vnet_cidr
    subnet_cidr         = var.network_config.subnet_cidr
    dns_servers         = var.network_config.dns_servers
    private_ip_address  = azurerm_network_interface.main.private_ip_address
  }
}