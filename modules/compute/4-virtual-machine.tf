# =============================================================================
# VIRTUAL MACHINE
# =============================================================================
# This file creates the main virtual machine that will host the N8N
# automation platform. The VM is configured with Ubuntu 22.04 LTS and
# includes security hardening and monitoring capabilities.

resource "azurerm_linux_virtual_machine" "main" {
  name                = "${local.compute_names.virtual_machine}-${random_id.vm_suffix.hex}"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  
  # Security configuration
  disable_password_authentication = true
  
  # Resource management
  #delete_os_disk_on_termination = true
  
  # Network configuration
  network_interface_ids = [
    var.network_interface_id,
  ]

  # Admin user configuration
  admin_username = var.admin_username

  # SSH key configuration using the provided public key
  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  # OS disk configuration
  os_disk {
    caching              = var.vm_config.os_disk.caching
    storage_account_type = var.vm_config.os_disk.storage_account_type
    disk_size_gb         = var.vm_config.os_disk.disk_size_gb
    
    # Disk encryption (consider enabling for production)
    # encryption_set_id = var.disk_encryption_set_id
  }

  # Source image configuration
  source_image_reference {
    publisher = var.vm_config.source_image.publisher
    offer     = var.vm_config.source_image.offer
    sku       = var.vm_config.source_image.sku
    version   = var.vm_config.source_image.version
  }

  # Boot diagnostics configuration
  dynamic "boot_diagnostics" {
    for_each = var.vm_config.boot_diagnostics_enabled ? [1] : []
    content {
      storage_account_uri = azurerm_storage_account.main.primary_blob_endpoint
    }
  }

  # Apply common tags plus VM-specific tags
  tags = merge(var.common_tags, {
    Component    = "Compute"
    Type         = "Virtual Machine"
    Description  = "N8N automation platform virtual machine"
    VMSize       = var.vm_size
    OSType       = "Linux"
    OSVersion    = var.vm_config.source_image.sku
    AdminUser    = var.admin_username
  })

  # Lifecycle management for virtual machine
  lifecycle {
    prevent_destroy = false # Set to true for production environments
    
    # Ignore changes to tags that might be applied by Azure policies
    ignore_changes = [
      tags["CreatedAt"],
      tags["LastModified"],
      source_image_reference[0].version  # Allow automatic image updates
    ]
  }

  # Explicit dependencies to ensure proper creation order
  depends_on = [
    azurerm_storage_account.main,
    azurerm_public_ip.main
  ]
}