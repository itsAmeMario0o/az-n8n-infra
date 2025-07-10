# =============================================================================
# SECURITY MODULE - VARIABLES
# =============================================================================
# This file defines input variables for the security module. These variables
# allow the module to be configured from the root module while maintaining
# flexibility and reusability across different environments.

# -----------------------------------------------------------------------------
# Required Variables
# -----------------------------------------------------------------------------

variable "resource_group_name" {
  description = "Name of the Azure resource group where security resources will be created"
  type        = string
  
  validation {
    condition     = length(var.resource_group_name) > 0
    error_message = "Resource group name cannot be empty."
  }
}

variable "location" {
  description = "Azure region where security resources will be deployed"
  type        = string
  
  validation {
    condition     = length(var.location) > 0
    error_message = "Location cannot be empty."
  }
}

variable "resource_prefix" {
  description = "Prefix for all security resource names to ensure uniqueness"
  type        = string
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.resource_prefix))
    error_message = "Resource prefix must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "security_rules" {
  description = "Map of security rules to create in the network security group"
  type = map(object({
    name                     = string
    priority                 = number
    direction               = string
    access                  = string
    protocol                = string
    source_port_range       = string
    destination_port_range  = string
    description             = string
  }))
  
  validation {
    condition = alltrue([
      for rule in var.security_rules :
      contains(["Inbound", "Outbound"], rule.direction) &&
      contains(["Allow", "Deny"], rule.access) &&
      contains(["Tcp", "Udp", "*"], rule.protocol) &&
      rule.priority >= 100 && rule.priority <= 4096
    ])
    error_message = "Security rules must have valid direction (Inbound/Outbound), access (Allow/Deny), protocol (Tcp/Udp/*), and priority (100-4096)."
  }
}

variable "security_cidrs" {
  description = "CIDR blocks allowed for different types of access"
  type = object({
    ssh_allowed = list(string)
    web_allowed = list(string)
  })
  
  validation {
    condition = alltrue([
      for cidr in concat(var.security_cidrs.ssh_allowed, var.security_cidrs.web_allowed) :
      can(cidrhost(cidr, 0))
    ])
    error_message = "All CIDR blocks must be valid CIDR notation."
  }
}

variable "common_tags" {
  description = "Common tags to be applied to all security resources"
  type        = map(string)
  default     = {}
}

variable "network_interface_id" {
  description = "ID of the network interface to associate with the security group"
  type        = string
  
  validation {
    condition     = length(var.network_interface_id) > 0
    error_message = "Network interface ID cannot be empty."
  }
}