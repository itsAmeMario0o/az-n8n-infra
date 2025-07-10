# =============================================================================
# SUBNET CONFIGURATION
# =============================================================================
# This file creates the subnet within the virtual network where the N8N
# virtual machine will be deployed. The subnet provides network segmentation
# and defines the address range for VM network interfaces.

resource "azurerm_subnet" "main" {
  name                 = local.network_names.subnet
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.network_config.subnet_cidr]

  # Lifecycle management to ensure proper dependency handling
  lifecycle {
    # Create replacement subnet before destroying the old one
    create_before_destroy = true
  }

  # Explicit dependency to ensure VNet exists before subnet creation
  depends_on = [azurerm_virtual_network.main]
}