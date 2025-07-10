# =============================================================================
# SECURITY MODULE - LOCAL VALUES
# =============================================================================
# This file contains local values and computed logic specific to security
# resources. These locals help maintain consistency and reduce duplication
# within the security module.

locals {
  # ---------------------------------------------------------------------------
  # Security Resource Names
  # ---------------------------------------------------------------------------
  # Standardized naming for all security resources to ensure consistency
  # and easy identification within the Azure subscription.
  
  security_names = {
    network_security_group = "${var.resource_prefix}-nsg"
  }
  
  # ---------------------------------------------------------------------------
  # Security Rules Processing
  # ---------------------------------------------------------------------------
  # Process the security rules to add CIDR blocks dynamically based on rule type
  
  processed_security_rules = {
    for rule_name, rule_config in var.security_rules : rule_name => merge(rule_config, {
      # Assign appropriate CIDR blocks based on rule type
      source_address_prefixes = rule_name == "ssh" ? var.security_cidrs.ssh_allowed : var.security_cidrs.web_allowed
    })
  }
  
  # ---------------------------------------------------------------------------
  # Security Rule Validation
  # ---------------------------------------------------------------------------
  # Validate that all required security rules have valid configurations
  
  required_ports = ["22", "80", "443"]
  configured_ports = [for rule in var.security_rules : rule.destination_port_range]
  
  # Check if all required ports are configured
  all_ports_configured = length(setintersection(local.required_ports, local.configured_ports)) == length(local.required_ports)
}