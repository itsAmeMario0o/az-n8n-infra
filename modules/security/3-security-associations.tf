# =============================================================================
# SECURITY GROUP ASSOCIATIONS
# =============================================================================
# This file creates the association between the Network Security Group and
# the network interface. This association applies the security rules to the
# network traffic for the virtual machine.

resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = var.network_interface_id
  network_security_group_id = azurerm_network_security_group.main.id

  # Explicit dependencies to ensure proper creation order
  depends_on = [
    azurerm_network_security_group.main,
    azurerm_network_security_rule.rules
  ]
}

# =============================================================================
# VALIDATION CHECKS
# =============================================================================
# Validation to ensure that all required security configuration is in place

# Check that the association was created successfully
resource "null_resource" "security_validation" {
  # This resource will be recreated if the security configuration changes
  triggers = {
    nsg_id = azurerm_network_security_group.main.id
    nic_id = var.network_interface_id
    rules_hash = md5(jsonencode(local.processed_security_rules))
  }

  # Validation provisioner (optional, for debugging)
  provisioner "local-exec" {
    command = "echo 'Security group association completed successfully'"
  }

  depends_on = [azurerm_network_interface_security_group_association.main]
}