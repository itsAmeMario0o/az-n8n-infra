# =============================================================================
# NETWORKING MODULE - LOCAL VALUES
# =============================================================================
# This file contains local values and computed logic specific to networking
# resources. These locals help maintain consistency and reduce duplication
# within the networking module.

locals {
  # ---------------------------------------------------------------------------
  # Network Resource Names
  # ---------------------------------------------------------------------------
  # Standardized naming for all networking resources to ensure consistency
  # and easy identification within the Azure subscription.
  
  network_names = {
    virtual_network   = "${var.resource_prefix}-vnet"
    subnet           = "${var.resource_prefix}-subnet"
    network_interface = "${var.resource_prefix}-nic"
  }
  
  # ---------------------------------------------------------------------------
  # Network Configuration Validation
  # ---------------------------------------------------------------------------
  # Validate that the subnet CIDR is within the VNet CIDR range
  
  vnet_cidr_prefix = tonumber(split("/", var.network_config.vnet_cidr)[1])
  subnet_cidr_prefix = tonumber(split("/", var.network_config.subnet_cidr)[1])
  
  # Ensure subnet CIDR is more specific (larger prefix) than VNet CIDR
  subnet_valid = local.subnet_cidr_prefix > local.vnet_cidr_prefix
  
  # ---------------------------------------------------------------------------
  # Network Interface Configuration
  # ---------------------------------------------------------------------------
  # Configuration for the network interface including IP allocation method
  # and DNS settings.
  
  nic_config = {
    name                          = local.network_names.network_interface
    private_ip_address_allocation = "Dynamic"
    dns_servers                   = var.network_config.dns_servers
  }
}