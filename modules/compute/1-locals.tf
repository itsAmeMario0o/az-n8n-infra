# =============================================================================
# COMPUTE MODULE - LOCAL VALUES
# =============================================================================
# This file contains local values and computed logic specific to compute
# resources. These locals help maintain consistency and reduce duplication
# within the compute module.

locals {
  # ---------------------------------------------------------------------------
  # Compute Resource Names
  # ---------------------------------------------------------------------------
  # Standardized naming for all compute resources to ensure consistency
  # and easy identification within the Azure subscription.
  
  compute_names = {
    virtual_machine     = "${var.resource_prefix}-vm"
    public_ip          = "${var.resource_prefix}-pip"
    storage_account    = replace("${var.resource_prefix}sa", "-", "")  # Storage accounts can't have hyphens
    vm_extension       = "n8n-setup"
  }
  
  # ---------------------------------------------------------------------------
  # Storage Account Configuration
  # ---------------------------------------------------------------------------
  # Storage account configuration for boot diagnostics with validation
  
  storage_config = {
    name                     = "${local.compute_names.storage_account}${random_id.storage_suffix.hex}"
    account_tier             = "Standard"
    account_replication_type = "LRS"
    account_kind            = "StorageV2"
  }
  
  # ---------------------------------------------------------------------------
  # VM Extension Configuration
  # ---------------------------------------------------------------------------
  # Configuration for the custom script extension that sets up N8N
  
  vm_extension_config = {
    name                 = local.compute_names.vm_extension
    publisher            = "Microsoft.Azure.Extensions"
    type                 = "CustomScript"
    type_handler_version = "2.1"
    
    # Installation command for N8N repository
    install_command = join(" && ", [
      "apt-get update",
      "apt-get install -y git",
      "git clone ${var.n8n_config.repository_url} ${var.n8n_config.install_directory}",
      "chown -R ${var.admin_username}:${var.admin_username} ${var.n8n_config.install_directory}"
    ])
  }
  
  # ---------------------------------------------------------------------------
  # VM Configuration Validation
  # ---------------------------------------------------------------------------
  # Validate VM configuration parameters
  
  vm_size_valid = contains([
    for size in data.azurerm_virtual_machine_sizes.available.sizes : size.name
  ], var.vm_size)
  
  # ---------------------------------------------------------------------------
  # Public IP Configuration
  # ---------------------------------------------------------------------------
  # Public IP configuration with DNS label
  
  public_ip_config = {
    name              = local.compute_names.public_ip
    allocation_method = "Static"
    sku              = "Standard"
    dns_label        = "${var.resource_prefix}-${random_id.vm_suffix.hex}"
  }
}