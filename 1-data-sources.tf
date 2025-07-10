# =============================================================================
# EXTERNAL DATA SOURCES
# =============================================================================
# This file contains data sources that fetch information from external
# services and Azure APIs to be used throughout the infrastructure deployment.

# -----------------------------------------------------------------------------
# Public IP Discovery
# -----------------------------------------------------------------------------
# Automatically discover the public IP address of the machine running
# Terraform to configure security group rules for restricted access.

data "http" "my_public_ip" {
  count = var.enable_dynamic_ip_security ? 1 : 0
  url   = "https://ifconfig.me/ip"

  # Retry configuration for reliability
  retry {
    attempts = 3
    min_delay_ms = 1000
  }
}

# -----------------------------------------------------------------------------
# Azure Client Configuration
# -----------------------------------------------------------------------------
# Get information about the current Azure client configuration including
# subscription ID, tenant ID, and object ID for tagging and auditing purposes.

data "azurerm_client_config" "current" {}

# -----------------------------------------------------------------------------
# Azure Regions
# -----------------------------------------------------------------------------
# Get information about the specified Azure region to validate location
# and retrieve region-specific configuration options.

data "azurerm_location" "available" {
  location = var.location
}