# =============================================================================
# MODULE INSTANTIATION
# =============================================================================
# This file instantiates all the modules required for the N8N deployment.
# Modules are called in dependency order to ensure proper resource creation
# and configuration. Each module encapsulates a specific aspect of the infrastructure.

# -----------------------------------------------------------------------------
# SSH Keys Module
# -----------------------------------------------------------------------------
# Generate SSH key pairs for secure VM access. This module creates both
# public and private keys and saves them locally for use in VM configuration.

module "ssh_keys" {
  source = "./modules/ssh-keys"

  # SSH configuration object with all required parameters
  ssh_config = {
    algorithm            = "RSA"
    rsa_bits            = 4096
    private_key_filename = "${local.resource_prefix}-private-key.pem"
    public_key_filename  = "${local.resource_prefix}-public-key.pub"
    key_directory       = "ssh-keys"
  }
  
  # Common tags
  common_tags = local.common_tags
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

  # Explicit dependency to ensure resource group exists
  depends_on = [azurerm_resource_group.n8n]
}

# -----------------------------------------------------------------------------
# Compute Module
# -----------------------------------------------------------------------------
# Create the virtual machine, public IP, storage account, and VM extensions.
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

  # Explicit dependencies
  depends_on = [
    azurerm_resource_group.n8n,
    module.networking,
    module.ssh_keys
  ]
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
# Public IP Association
# -----------------------------------------------------------------------------
# Associate the public IP with the network interface using a separate resource.
# This avoids circular dependencies by using Azure CLI to update the NIC.

resource "null_resource" "public_ip_association" {
  # Use Azure CLI to associate the public IP with the network interface
  provisioner "local-exec" {
    command = <<-EOT
      az network nic ip-config update \
        --resource-group ${azurerm_resource_group.n8n.name} \
        --nic-name ${module.networking.network_interface_name} \
        --name internal \
        --public-ip-address ${module.compute.public_ip_id}
    EOT
  }

  # Clean up on destroy
  provisioner "local-exec" {
    when = destroy
    command = <<-EOT
      az network nic ip-config update \
        --resource-group ${self.triggers.resource_group} \
        --nic-name ${self.triggers.nic_name} \
        --name internal \
        --remove publicIpAddress || true
    EOT
  }

  # Store values for destroy-time provisioner
  triggers = {
    resource_group = azurerm_resource_group.n8n.name
    nic_name       = module.networking.network_interface_name
    public_ip_id   = module.compute.public_ip_id
  }

  # Ensure all modules are created before running this
  depends_on = [
    module.networking,
    module.compute,
    module.security
  ]
}