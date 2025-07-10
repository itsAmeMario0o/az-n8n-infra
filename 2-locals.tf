# =============================================================================
# LOCAL VALUES AND COMPUTED LOGIC
# =============================================================================
# This file contains local values and complex logic used throughout the
# infrastructure deployment. Locals help reduce duplication and provide
# computed values based on input variables and data sources.

locals {
  # ---------------------------------------------------------------------------
  # Common Resource Naming
  # ---------------------------------------------------------------------------
  # Standardized naming convention for all resources to ensure consistency
  # and easy identification across the Azure subscription.
  
  resource_prefix = "${var.project_name}-${var.environment}"
  
  # ---------------------------------------------------------------------------
  # Common Resource Tags
  # ---------------------------------------------------------------------------
  # Standard tags applied to all resources for organization, cost tracking,
  # and operational management. Includes creation metadata for auditing.
  
  common_tags = {
    Project       = var.project_name
    Environment   = var.environment
    ManagedBy     = "Terraform"
    CreatedBy     = data.azurerm_client_config.current.object_id
  }
  
  # ---------------------------------------------------------------------------
  # Network Configuration
  # ---------------------------------------------------------------------------
  # Network-related computed values including CIDR blocks and IP configurations
  # for VNet, subnets, and security group rules.
  
  network_config = {
    vnet_cidr          = "10.0.0.0/16"
    subnet_cidr        = "10.0.1.0/24"
    dns_servers        = ["168.63.129.16"] # Azure-provided DNS
  }
  
  # ---------------------------------------------------------------------------
  # Security Configuration
  # ---------------------------------------------------------------------------
  # Security-related computed values including IP discovery for access control
  # and security rule definitions.
  
  # Dynamically discovered public IP for security rules
  my_public_ip_cidr = var.enable_dynamic_ip_security ? "${chomp(data.http.my_public_ip[0].response_body)}/32" : null
  
  # Security group allowed CIDR blocks based on dynamic IP setting
  security_cidrs = {
    ssh_allowed = var.enable_dynamic_ip_security ? [local.my_public_ip_cidr] : var.allowed_ssh_cidr_blocks
    web_allowed = var.enable_dynamic_ip_security ? [local.my_public_ip_cidr] : var.allowed_web_cidr_blocks
  }
  
  # Security rules configuration for dynamic creation
  security_rules = {
    ssh = {
      name                     = "SSH"
      priority                 = 1001
      direction               = "Inbound"
      access                  = "Allow"
      protocol                = "Tcp"
      source_port_range       = "*"
      destination_port_range  = "22"
      description             = "Allow SSH access from authorized IPs"
    }
    https = {
      name                     = "HTTPS"
      priority                 = 1002
      direction               = "Inbound"
      access                  = "Allow"
      protocol                = "Tcp"
      source_port_range       = "*"
      destination_port_range  = "443"
      description             = "Allow HTTPS access for web interface"
    }
    http = {
      name                     = "HTTP"
      priority                 = 1003
      direction               = "Inbound"
      access                  = "Allow"
      protocol                = "Tcp"
      source_port_range       = "*"
      destination_port_range  = "80"
      description             = "Allow HTTP access for web interface and redirects"
    }
  }
  
  # ---------------------------------------------------------------------------
  # Compute Configuration
  # ---------------------------------------------------------------------------
  # VM-related computed values including sizing, storage, and configuration
  # options based on environment and requirements.
  
  vm_config = {
    # OS disk configuration based on environment
    os_disk = {
      caching              = "ReadWrite"
      storage_account_type = var.os_disk_type
      disk_size_gb         = var.os_disk_size_gb
    }
    
    # VM image reference for Ubuntu 22.04 LTS
    source_image = {
      publisher = "Canonical"
      offer     = "0001-com-ubuntu-server-jammy"
      sku       = "22_04-lts-gen2"
      version   = "latest"
    }
    
    # Boot diagnostics storage configuration
    boot_diagnostics_enabled = true
  }
  
  # ---------------------------------------------------------------------------
  # SSH Key Configuration
  # ---------------------------------------------------------------------------
  # SSH key-related computed values for file naming and permissions
  
  ssh_config = {
    algorithm    = "RSA"
    rsa_bits     = 4096
    private_key_filename = "${local.resource_prefix}-private-key.pem"
    public_key_filename  = "${local.resource_prefix}-public-key.pub"
    key_directory       = "ssh-keys"
  }
  
  # ---------------------------------------------------------------------------
  # N8N Installation Configuration
  # ---------------------------------------------------------------------------
  # Configuration for N8N installation including repository and setup commands
  
  n8n_config = {
    repository_url    = "https://github.com/kossakovsky/n8n-installer.git"
    install_directory = "/opt/n8n-installer"
    installer_script  = "installer.sh"
  }
}