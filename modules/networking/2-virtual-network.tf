# =============================================================================
# VIRTUAL NETWORK
# =============================================================================
# This file creates the VNet that provides network infrastructure 

resource "azurerm_virtual_network" "main" {
  name                = local.network_names.virtual_network
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.network_config.vnet_cidr]
  dns_servers         = var.network_config.dns_servers

  # Apply common tags plus networking-specific tags
  tags = merge(var.common_tags, {
    Component   = "Networking"
    Type        = "Virtual Network"
  })

  # Lifecycle management to prevent accidental deletion
  lifecycle {
    prevent_destroy = false # Set to true for production environments
    
  }
}