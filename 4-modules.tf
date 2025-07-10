# =============================================================================
# MODULE INSTANTIATION
# =============================================================================
# This file instantiates all the modules required for the deployment.
# Modules are called in dependency order to ensure proper resource creation
# and configuration. Each module encapsulates a specific aspect of the infrastructure.

# -----------------------------------------------------------------------------
# SSH Keys Module
# -----------------------------------------------------------------------------
# Generate SSH key pairs for secure VM access. This module creates both
# public and private keys and saves them locally for use in VM configuration.

module "ssh_keys" {
  source = "./modules/ssh-keys"

  # Pass computed values from locals
  #project_name    = var.project_name
  #environment     = var.environment
  #resource_prefix = local.resource_prefix
  #ssh_config      = local.ssh_config
  #common_tags     = local.common_tags
}

# -----------------------------------------------------------------------------
# Networking Module
# -----------------------------------------------------------------------------
# Create the network infrastructure including VNet, subnet, and network interface.
# This module establishes the network foundation for the VM deployment.

module "networking" {
  source = "./modules/networking"

  # Resource configuration
  resource_group_name = azurerm_resource_group.n8n.name
  location           = azurerm_resource_group.n8n.location
  resource_prefix    = local.resource_prefix
  
  # Network configuration from locals
  network_config = local.network_config
  common_tags    = local.common_tags
  
  # Public IP dependency from compute module
  public_ip_id = module.compute.public_ip_id

  # Explicit dependency to ensure resource group exists
  depends_on = [azurerm_resource_group.n8n]
}

# -----------------------------------------------------------------------------
# Security Module
# -----------------------------------------------------------------------------
# Create and configure network security groups with dynamic rules based on
# the security configuration. This module handles all firewall and access control.

module "security" {
  source = "./modules/security"

  # Resource configuration
  resource_group_name = azurerm_resource_group.n8n.name
  location           = azurerm_resource_group.n8n.location
  resource_prefix    = local.resource_prefix
  
  # Security configuration from locals
  security_rules     = local.security_rules
  security_cidrs     = local.security_cidrs
  common_tags        = local.common_tags
  
  # Network interface for security group association
  network_interface_id = module.networking.network_interface_id

  # Explicit dependencies to ensure proper creation order
  depends_on = [
    azurerm_resource_group.n8n,
    module.networking
  ]
}

# -----------------------------------------------------------------------------
# Compute Module
# -----------------------------------------------------------------------------
# Create the virtual machine, storage account, and VM extensions for N8N.
# This module handles all compute resources and N8N installation setup.

module "compute" {
  source = "./modules/compute"

  # Resource configuration
  resource_group_name = azurerm_resource_group.n8n.name
  location           = azurerm_resource_group.n8n.location
  resource_prefix    = local.resource_prefix
  
  # VM configuration from locals and variables
  vm_size           = var.vm_size
  admin_username    = var.admin_username
  vm_config         = local.vm_config
  n8n_config        = local.n8n_config
  common_tags       = local.common_tags
  
  # SSH key from ssh-keys module
  ssh_public_key = module.ssh_keys.public_key_openssh
  
  # Network interface from networking module
  network_interface_id = module.networking.network_interface_id

  # Explicit dependencies to ensure all prerequisites are met
  depends_on = [
    azurerm_resource_group.n8n,
    module.networking,
    module.security,
    module.ssh_keys
  ]
}