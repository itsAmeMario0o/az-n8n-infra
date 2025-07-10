# =============================================================================
# NETWORK SECURITY GROUP
# =============================================================================
# This file creates the Network Security Group (NSG) and associated security
# rules for the deployment. The NSG acts as a firewall to control network
# traffic to and from the virtual machine.

resource "azurerm_network_security_group" "main" {
  name                = local.security_names.network_security_group
  location            = var.location
  resource_group_name = var.resource_group_name

  # Apply common tags plus security-specific tags
  tags = merge(var.common_tags, {
    Component   = "Security"
    Type        = "Network Security Group"
  })

  # Lifecycle management to prevent accidental deletion
  lifecycle {
    prevent_destroy = false # Set to true for production environments
    
    # Ignore changes to tags that might be applied by Azure policies
    ignore_changes = [
      tags["CreatedAt"],
      tags["LastModified"]
    ]
  }
}

# =============================================================================
# DYNAMIC SECURITY RULES
# =============================================================================
# Create security rules dynamically based on the security_rules variable.
# This approach allows for flexible rule configuration while maintaining
# consistency and reducing code duplication.

resource "azurerm_network_security_rule" "rules" {
  for_each = local.processed_security_rules

  name                        = each.value.name
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_port_range          = each.value.source_port_range
  destination_port_range     = each.value.destination_port_range
  source_address_prefixes    = each.value.source_address_prefixes
  destination_address_prefix = "*"
  description                = each.value.description
  
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.main.name

  # Explicit dependency to ensure NSG exists before rules
  depends_on = [azurerm_network_security_group.main]
}