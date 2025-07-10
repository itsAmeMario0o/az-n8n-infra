# =============================================================================
# NETWORK INTERFACE
# =============================================================================
# This file creates the network interface that will be attached to the N8N
# virtual machine. The NIC provides the connection between the VM and the
# virtual network, including IP address configuration.

resource "azurerm_network_interface" "main" {
  name                = local.nic_config.name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_servers         = local.nic_config.dns_servers

  # IP configuration for the network interface
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = local.nic_config.private_ip_address_allocation
    public_ip_address_id          = var.public_ip_id
  }

  # Apply common tags plus networking-specific tags
  tags = merge(var.common_tags, {
    Component   = "Networking"
    Type        = "Network Interface"
    SubnetId    = azurerm_subnet.main.id
  })

  # Lifecycle management to ensure proper creation order
  lifecycle {
    # Create replacement NIC before destroying the old one
    create_before_destroy = true
  }

  # Explicit dependencies to ensure proper creation order
  depends_on = [
    azurerm_virtual_network.main,
    azurerm_subnet.main
  ]
}