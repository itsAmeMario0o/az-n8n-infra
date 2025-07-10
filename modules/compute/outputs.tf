# =============================================================================
# COMPUTE MODULE - OUTPUTS
# =============================================================================
# This file defines output values from the compute module that can be
# consumed by other modules or the root configuration. Outputs provide
# essential information about created compute resources.

# -----------------------------------------------------------------------------
# Virtual Machine Outputs
# -----------------------------------------------------------------------------

output "virtual_machine_name" {
  description = "Name of the created virtual machine"
  value       = azurerm_linux_virtual_machine.main.name
}

output "virtual_machine_id" {
  description = "Resource ID of the created virtual machine"
  value       = azurerm_linux_virtual_machine.main.id
}

output "virtual_machine_private_ip" {
  description = "Private IP address of the virtual machine"
  value       = azurerm_linux_virtual_machine.main.private_ip_address
}

output "virtual_machine_public_ip" {
  description = "Public IP address of the virtual machine"
  value       = azurerm_linux_virtual_machine.main.public_ip_address
}

# -----------------------------------------------------------------------------
# Public IP Outputs
# -----------------------------------------------------------------------------

output "public_ip_id" {
  description = "Resource ID of the public IP address"
  value       = azurerm_public_ip.main.id
}

output "public_ip_address" {
  description = "The actual public IP address assigned"
  value       = azurerm_public_ip.main.ip_address
}

output "public_ip_fqdn" {
  description = "Fully qualified domain name of the public IP"
  value       = azurerm_public_ip.main.fqdn
}

# -----------------------------------------------------------------------------
# Storage Account Outputs
# -----------------------------------------------------------------------------

output "storage_account_name" {
  description = "Name of the storage account used for boot diagnostics"
  value       = azurerm_storage_account.main.name
}

output "storage_account_id" {
  description = "Resource ID of the storage account"
  value       = azurerm_storage_account.main.id
}

output "storage_account_primary_endpoint" {
  description = "Primary blob endpoint of the storage account"
  value       = azurerm_storage_account.main.primary_blob_endpoint
}

# -----------------------------------------------------------------------------
# VM Extension Outputs
# -----------------------------------------------------------------------------

output "vm_extension_name" {
  description = "Name of the VM extension"
  value       = azurerm_virtual_machine_extension.n8n_setup.name
}

output "vm_extension_id" {
  description = "Resource ID of the VM extension"
  value       = azurerm_virtual_machine_extension.n8n_setup.id
}

# -----------------------------------------------------------------------------
# VM Configuration Outputs
# -----------------------------------------------------------------------------

output "vm_configuration" {
  description = "Complete virtual machine configuration summary"
  value = {
    name           = azurerm_linux_virtual_machine.main.name
    size           = var.vm_size
    admin_username = var.admin_username
    
    network = {
      private_ip = azurerm_linux_virtual_machine.main.private_ip_address
      public_ip  = azurerm_public_ip.main.ip_address
      fqdn       = azurerm_public_ip.main.fqdn
    }
    
    storage = {
      os_disk = {
        size_gb      = var.vm_config.os_disk.disk_size_gb
        storage_type = var.vm_config.os_disk.storage_account_type
        caching      = var.vm_config.os_disk.caching
      }
      boot_diagnostics = {
        enabled           = var.vm_config.boot_diagnostics_enabled
        storage_account   = azurerm_storage_account.main.name
        storage_endpoint  = azurerm_storage_account.main.primary_blob_endpoint
      }
    }
    
    n8n_setup = {
      repository_url    = var.n8n_config.repository_url
      install_directory = var.n8n_config.install_directory
      installer_script  = var.n8n_config.installer_script
      extension_name    = azurerm_virtual_machine_extension.n8n_setup.name
    }
  }
}