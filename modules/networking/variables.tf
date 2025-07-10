# =============================================================================
# NETWORKING MODULE - VARIABLES
# =============================================================================
# This file defines input variables for the networking module. These variables
# allow the module to be configured from the root module while maintaining
# flexibility and reusability across different environments.

# -----------------------------------------------------------------------------
# Required Variables
# -----------------------------------------------------------------------------

variable "resource_group_name" {
  description = "Name of the Azure resource group where networking resources will be created"
  type        = string
  
  validation {
    condition     = length(var.resource_group_name) > 0
    error_message = "Resource group name cannot be empty."
  }
}

variable "location" {
  description = "Azure region where networking resources will be deployed"
  type        = string
  
  validation {
    condition     = length(var.location) > 0
    error_message = "Location cannot be empty."
  }
}

variable "resource_prefix" {
  description = "Prefix for all networking resource names to ensure uniqueness"
  type        = string
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.resource_prefix))
    error_message = "Resource prefix must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "network_config" {
  description = "Network configuration including CIDR blocks and DNS settings"
  type = object({
    vnet_cidr   = string
    subnet_cidr = string
    dns_servers = list(string)
  })
  
  validation {
    condition = can(cidrhost(var.network_config.vnet_cidr, 0)) && can(cidrhost(var.network_config.subnet_cidr, 0))
    error_message = "VNet and subnet CIDR blocks must be valid CIDR notation."
  }
}

variable "common_tags" {
  description = "Common tags to be applied to all networking resources"
  type        = map(string)
  default     = {}
}

variable "public_ip_id" {
  description = "ID of the public IP address to associate with the network interface"
  type        = string
  
  validation {
    condition     = length(var.public_ip_id) > 0
    error_message = "Public IP ID cannot be empty."
  }
}