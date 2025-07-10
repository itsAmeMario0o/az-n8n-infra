# =============================================================================
# PUBLIC IP ADDRESS
# =============================================================================
# This file creates the public IP address that will be associated with the
# N8N virtual machine. The public IP provides external connectivity for
# SSH access and web interface access.

# Random suffix for unique naming
resource "random_id" "vm_suffix" {
  byte_length = 4
}

resource "azurerm_public_ip" "main" {
  name                = local.public_ip_config.name
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = local.public_ip_config.allocation_method
  sku                = local.public_ip_config.sku
  domain_name_label   = local.public_ip_config.dns_label

  # Apply common tags plus compute-specific tags
  tags = merge(var.common_tags, {
    Component   = "Compute"
    Type        = "Public IP"
    DNSLabel    = local.public_ip_config.dns_label
  })

  # Lifecycle management for public IP
  lifecycle {
    prevent_destroy = false # Set to true for production environments
    
    # Create replacement before destroying to maintain connectivity
    create_before_destroy = true
  }
}