# =============================================================================
# COMPUTE MODULE - VARIABLES
# =============================================================================
# This file defines input variables for the compute module. These variables
# allow the module to be configured from the root module while maintaining
# flexibility and reusability across different environments.

# -----------------------------------------------------------------------------
# Required Variables
# -----------------------------------------------------------------------------

variable "resource_group_name" {
  description = "Name of the Azure resource group where compute resources will be created"
  type        = string
  
  validation {
    condition     = length(var.resource_group_name) > 0
    error_message = "Resource group name cannot be empty."
  }
}

variable "location" {
  description = "Azure region where compute resources will be deployed"
  type        = string
  
  validation {
    condition     = length(var.location) > 0
    error_message = "Location cannot be empty."
  }
}

variable "resource_prefix" {
  description = "Prefix for all compute resource names to ensure uniqueness"
  type        = string
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.resource_prefix))
    error_message = "Resource prefix must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "vm_size" {
  description = "Size/SKU of the virtual machine"
  type        = string
  
  validation {
    condition     = can(regex("^Standard_[A-Z][0-9]+[a-z]*[_v]?[0-9]*$", var.vm_size))
    error_message = "VM size must be a valid Azure VM size (e.g., Standard_B2s, Standard_D2s_v3)."
  }
}

variable "admin_username" {
  description = "Administrator username for the virtual machine"
  type        = string
  
  validation {
    condition     = can(regex("^[a-z0-9]+$", var.admin_username)) && length(var.admin_username) >= 3
    error_message = "Admin username must be at least 3 characters long and contain only lowercase letters and numbers."
  }
}

variable "ssh_public_key" {
  description = "SSH public key content for VM authentication"
  type        = string
  
  validation {
    condition     = can(regex("^ssh-rsa AAAA[0-9A-Za-z+/]+[=]{0,3}( .*)?$", var.ssh_public_key))
    error_message = "SSH public key must be a valid RSA public key."
  }
}

variable "network_interface_id" {
  description = "ID of the network interface to attach to the virtual machine"
  type        = string
  
  validation {
    condition     = length(var.network_interface_id) > 0
    error_message = "Network interface ID cannot be empty."
  }
}

variable "vm_config" {
  description = "Virtual machine configuration including OS disk and image settings"
  type = object({
    os_disk = object({
      caching              = string
      storage_account_type = string
      disk_size_gb         = number
    })
    source_image = object({
      publisher = string
      offer     = string
      sku       = string
      version   = string
    })
    boot_diagnostics_enabled = bool
  })
  
  validation {
    condition = contains(["ReadOnly", "ReadWrite", "None"], var.vm_config.os_disk.caching)
    error_message = "OS disk caching must be ReadOnly, ReadWrite, or None."
  }
  
  validation {
    condition = contains(["Standard_LRS", "StandardSSD_LRS", "Premium_LRS"], var.vm_config.os_disk.storage_account_type)
    error_message = "OS disk storage account type must be Standard_LRS, StandardSSD_LRS, or Premium_LRS."
  }
  
  validation {
    condition = var.vm_config.os_disk.disk_size_gb >= 30 && var.vm_config.os_disk.disk_size_gb <= 2048
    error_message = "OS disk size must be between 30 and 2048 GB."
  }
}

variable "n8n_config" {
  description = "N8N application configuration including repository and installation settings"
  type = object({
    repository_url    = string
    install_directory = string
    installer_script  = string
  })
  
  validation {
    condition = can(regex("^https://github\\.com/[^/]+/[^/]+\\.git$", var.n8n_config.repository_url))
    error_message = "Repository URL must be a valid GitHub repository URL."
  }
  
  validation {
    condition = can(regex("^/[a-zA-Z0-9/_-]+$", var.n8n_config.install_directory))
    error_message = "Install directory must be a valid absolute path."
  }
}

variable "common_tags" {
  description = "Common tags to be applied to all compute resources"
  type        = map(string)
  default     = {}
}