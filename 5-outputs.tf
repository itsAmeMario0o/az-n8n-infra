# =============================================================================
# ROOT OUTPUTS
# =============================================================================
# This file organizes and exposes outputs from all modules in a structured
# format for easy consumption by users and other Terraform configurations.
# Outputs are grouped by functional area for better organization.

# -----------------------------------------------------------------------------
# Deployment Information
# -----------------------------------------------------------------------------
# High-level information about the deployment including discovered public IP
# and security configuration status.

output "deployment_info" {
  description = "General deployment information and configuration"
  value = {
    project_name    = var.project_name
    environment     = var.environment
    location        = var.location
    resource_prefix = local.resource_prefix
    
    # Dynamic IP security configuration
    dynamic_ip_enabled = var.enable_dynamic_ip_security
    discovered_public_ip = var.enable_dynamic_ip_security ? chomp(data.http.my_public_ip[0].response_body) : "Disabled"
    
    # Creation metadata
    created_by      = data.azurerm_client_config.current.object_id
    subscription_id = data.azurerm_client_config.current.subscription_id
  }
}

# -----------------------------------------------------------------------------
# Resource Group Information
# -----------------------------------------------------------------------------
# Information about the main resource group containing all resources.

output "resource_group" {
  description = "Resource group information"
  value = {
    name     = azurerm_resource_group.n8n.name
    location = azurerm_resource_group.n8n.location
    id       = azurerm_resource_group.n8n.id
  }
}

# -----------------------------------------------------------------------------
# Network Information
# -----------------------------------------------------------------------------
# Network configuration details from the networking module including
# VNet, subnet, and network interface information.

output "network" {
  description = "Network infrastructure information"
  value = {
    virtual_network = {
      name          = module.networking.virtual_network_name
      id            = module.networking.virtual_network_id
      address_space = module.networking.virtual_network_address_space
    }
    
    subnet = {
      name             = module.networking.subnet_name
      id               = module.networking.subnet_id
      address_prefixes = module.networking.subnet_address_prefixes
    }
    
    network_interface = {
      name               = module.networking.network_interface_name
      id                 = module.networking.network_interface_id
      private_ip_address = module.networking.private_ip_address
    }
    
    public_ip = {
      address = module.compute.public_ip_address
      fqdn    = module.compute.public_ip_fqdn
    }
  }
}

# -----------------------------------------------------------------------------
# Security Information
# -----------------------------------------------------------------------------
# Security configuration details including NSG information and allowed
# CIDR blocks for access control.

output "security" {
  description = "Security configuration information"
  value = {
    network_security_group = {
      name = module.security.network_security_group_name
      id   = module.security.network_security_group_id
    }
    
    security_rules = module.security.security_rules
    
    access_control = {
      ssh_allowed_cidrs = local.security_cidrs.ssh_allowed
      web_allowed_cidrs = local.security_cidrs.web_allowed
    }
  }
}

# -----------------------------------------------------------------------------
# Virtual Machine Information
# -----------------------------------------------------------------------------
# Comprehensive information about the deployed virtual machine including
# connection details and configuration.

output "virtual_machine" {
  description = "Virtual machine information and connection details"
  value = {
    name           = module.compute.virtual_machine_name
    id             = module.compute.virtual_machine_id
    size           = var.vm_size
    admin_username = var.admin_username
    
    # Connection information
    public_ip_address  = module.compute.public_ip_address
    private_ip_address = module.networking.private_ip_address
    
    # Storage information
    storage_account = {
      name = module.compute.storage_account_name
      id   = module.compute.storage_account_id
    }
  }
}

# -----------------------------------------------------------------------------
# SSH Key Information
# -----------------------------------------------------------------------------
# SSH key configuration and file locations for VM access.

output "ssh_keys" {
  description = "SSH key information and file locations"
  value = {
    private_key_path = module.ssh_keys.private_key_path
    public_key_path  = module.ssh_keys.public_key_path
    key_algorithm    = module.ssh_keys.key_algorithm
    key_size         = module.ssh_keys.key_size
  }
}

# -----------------------------------------------------------------------------
# N8N Application Information
# -----------------------------------------------------------------------------
# N8N-specific configuration and access information.

output "n8n_application" {
  description = "N8N application information and access details"
  value = {
    repository_path = local.n8n_config.install_directory
    installer_script = local.n8n_config.installer_script
    
    # Web interface URLs (available after manual installation)
    web_urls = {
      http  = "http://${module.compute.public_ip_address}"
      https = "https://${module.compute.public_ip_address}"
      direct = "http://${module.compute.public_ip_address}:5678"
    }
    
    # Installation instructions
    installation_command = "cd ${local.n8n_config.install_directory} && sudo bash ${local.n8n_config.installer_script}"
  }
}

# -----------------------------------------------------------------------------
# Connection Commands
# -----------------------------------------------------------------------------
# Ready-to-use commands for connecting to and managing the deployment.

output "connection_commands" {
  description = "Ready-to-use connection and management commands"
  value = {
    ssh_connect = "ssh -i ${module.ssh_keys.private_key_path} ${var.admin_username}@${module.compute.public_ip_address}"
    scp_upload = "scp -i ${module.ssh_keys.private_key_path} <local_file> ${var.admin_username}@${module.compute.public_ip_address}:~/"
    install_n8n = "cd ${local.n8n_config.install_directory} && sudo bash ${local.n8n_config.installer_script}"
    view_logs = "sudo journalctl -u n8n -f"
  }
}

# -----------------------------------------------------------------------------
# Quick Start Summary
# -----------------------------------------------------------------------------
# Consolidated summary for quick reference and next steps.

output "quick_start" {
  description = "Quick start summary and next steps"
  value = {
    summary = "N8N infrastructure deployed successfully. SSH to the VM and run the N8N installer to complete setup."
    
    next_steps = [
      "1. SSH to VM using: ssh -i ${module.ssh_keys.private_key_path} ${var.admin_username}@${module.compute.public_ip_address}",
      "2. Navigate to installer directory: cd ${local.n8n_config.install_directory}",
      "3. Review documentation with: cat README.md",
      "4. Run installer with: sudo bash ${local.n8n_config.installer_script}",
      "5. Access N8N at: http://${module.compute.public_ip_address}"
    ]
    
    important_notes = [
      "SSH keys are stored in ssh-keys/ directory",
      "N8N repository cloned to ${local.n8n_config.install_directory}",
      "Access restricted to ${var.enable_dynamic_ip_security ? "your current IP" : "configured CIDR blocks"}",
      "Default N8N port 5678 (proxied via port 80/443)"
    ]
  }
}