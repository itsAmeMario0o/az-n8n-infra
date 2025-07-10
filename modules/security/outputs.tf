# =============================================================================
# SECURITY MODULE - OUTPUTS
# =============================================================================
# This file defines output values from the security module that can be
# consumed by other modules or the root configuration. Outputs provide
# essential information about created security resources.

# -----------------------------------------------------------------------------
# Network Security Group Outputs
# -----------------------------------------------------------------------------

output "network_security_group_name" {
  description = "Name of the created network security group"
  value       = azurerm_network_security_group.main.name
}

output "network_security_group_id" {
  description = "Resource ID of the created network security group"
  value       = azurerm_network_security_group.main.id
}

# -----------------------------------------------------------------------------
# Security Rules Outputs
# -----------------------------------------------------------------------------

output "security_rules" {
  description = "Map of created security rules with their configurations"
  value = {
    for rule_name, rule in azurerm_network_security_rule.rules : rule_name => {
      name                     = rule.name
      priority                 = rule.priority
      direction               = rule.direction
      access                  = rule.access
      protocol                = rule.protocol
      source_port_range       = rule.source_port_range
      destination_port_range  = rule.destination_port_range
      source_address_prefixes = rule.source_address_prefixes
      description             = rule.description
    }
  }
}

output "security_rule_count" {
  description = "Number of security rules created"
  value       = length(azurerm_network_security_rule.rules)
}

# -----------------------------------------------------------------------------
# Security Configuration Outputs
# -----------------------------------------------------------------------------

output "security_configuration" {
  description = "Complete security configuration summary"
  value = {
    network_security_group = {
      name = azurerm_network_security_group.main.name
      id   = azurerm_network_security_group.main.id
    }
    
    allowed_cidrs = {
      ssh_allowed = var.security_cidrs.ssh_allowed
      web_allowed = var.security_cidrs.web_allowed
    }
    
    rule_summary = {
      total_rules = length(azurerm_network_security_rule.rules)
      inbound_rules = length([
        for rule in azurerm_network_security_rule.rules : rule
        if rule.direction == "Inbound"
      ])
      allowed_ports = [
        for rule in azurerm_network_security_rule.rules : rule.destination_port_range
        if rule.access == "Allow"
      ]
    }
  }
}

# -----------------------------------------------------------------------------
# Association Outputs
# -----------------------------------------------------------------------------

output "network_interface_association_id" {
  description = "ID of the network interface security group association"
  value       = azurerm_network_interface_security_group_association.main.id
}