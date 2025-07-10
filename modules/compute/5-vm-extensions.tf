# =============================================================================
# VIRTUAL MACHINE EXTENSIONS
# =============================================================================
# This file creates VM extensions that automatically configure the virtual
# machine after deployment. The main extension clones the N8N installer
# repository and prepares the environment for manual installation.

resource "azurerm_virtual_machine_extension" "n8n_setup" {
  name                 = local.vm_extension_config.name
  virtual_machine_id   = azurerm_linux_virtual_machine.main.id
  publisher            = local.vm_extension_config.publisher
  type                 = local.vm_extension_config.type
  type_handler_version = local.vm_extension_config.type_handler_version

  # Extension configuration
  settings = jsonencode({
    commandToExecute = local.vm_extension_config.install_command
  })

  # Apply common tags plus extension-specific tags
  tags = merge(var.common_tags, {
    Component   = "Compute"
    Type        = "VM Extension"
    Description = "N8N repository setup and preparation"
  })

  # Lifecycle management for VM extension
  lifecycle {
    # Replace extension if the command changes
    replace_triggered_by = [
      azurerm_linux_virtual_machine.main
    ]
  }

  # Explicit dependency to ensure VM is fully created before extension
  depends_on = [azurerm_linux_virtual_machine.main]
}

# =============================================================================
# EXTENSION STATUS MONITORING
# =============================================================================
# Optional: Add monitoring for extension status (useful for debugging)

resource "null_resource" "extension_status" {
  # This resource will be recreated if the extension configuration changes
  triggers = {
    vm_id = azurerm_linux_virtual_machine.main.id
    extension_id = azurerm_virtual_machine_extension.n8n_setup.id
    command_hash = md5(local.vm_extension_config.install_command)
  }

  # Optional: Add a provisioner to check extension status
  provisioner "local-exec" {
    command = "echo 'VM extension deployment completed for ${azurerm_linux_virtual_machine.main.name}'"
  }

  depends_on = [azurerm_virtual_machine_extension.n8n_setup]
}